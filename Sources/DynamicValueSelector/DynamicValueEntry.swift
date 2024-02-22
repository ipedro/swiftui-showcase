import SwiftUI

/// A view modifier that dynamically selects environment values for SwiftUI views.
/// This allows views to adapt their appearance or behavior based on selected values,
/// facilitating customization and dynamic UI updates.
struct DynamicValueContent<Key>: ViewModifier where Key: DynamicValueKey {
    /// The key type that identifies the dynamic value.
    let key: Key.Type

    // Simplify the dynamic value management by using ObservableObject for global state management.
    private class Store: ObservableObject {
        @Published var selection = Key.defaultCase
    }

    /// The current selection of the dynamic value.
    @StateObject private var store = Store()

    /// Initializes the selector with a specific dynamic value key.
    /// - Parameter key: The type of the dynamic value key to use for selection.
    init(_ key: Key.Type) {
        self.key = key
    }

    /// The content and behavior of the view.
    func body(content: Content) -> some View {
        content
            .environment(Key.keyPath, store.selection.value)
            .background {
                GeometryReader { _ in
                    Color.clear.preference(
                        key: DynamicValuePreferenceKey.self,
                        value: [.init(keyValuePicker)])
                }
            }
    }

    /// Creates a picker view for selecting a dynamic value.
    private var keyValuePicker: some View {
        Picker(Key.defaultDescription, selection: $store.selection) {
            ForEach(Key.allCases, id: \.self) { key in
                Text(key.rawValue).tag(key)
            }
        }
    }
}

/// Extends `String` to include a method for adding spaces before capital letters,
/// improving readability of camelCase strings.
private extension String {
    /// Adds spaces to a camelCase string to improve readability.
    /// - Returns: A new string with spaces added before each uppercase letter.
    func addingSpacesToCamelCase() -> String {
        return self.replacingOccurrences(of: "(?<=[a-z])(?=[A-Z])", with: " $0", options: .regularExpression, range: self.range(of: self))
    }
}

/// An extension on `View` to apply the `DynamicValueContent` modifier.
public extension View {
    /// Applies a dynamic value selector to the view.
    /// - Parameter key: The type of the dynamic value key.
    /// - Returns: A view modified to select and apply a dynamic environment value based on the given key.
    func dynamicValue<Key: DynamicValueKey>(_ key: Key.Type) -> some View {
        modifier(DynamicValueContent(key))
    }
}

public extension View {
    /// Applies a dynamic value selector to the view.
    /// - Parameter key: The type of the dynamic value key.
    /// - Returns: A view modified to select and apply a dynamic environment value based on the given key.
    func dynamicValueSelectorStyle<S: DynamicValueSelectorStyle>(_ style: S) -> some View {
        environment(\.selectorStyle, style)
    }
}

/// A protocol defining the requirements for keys used with dynamic environment values.
/// Types conforming to this protocol can be used to dynamically select and apply values to the SwiftUI environment.
public protocol DynamicValueKey: CaseIterable, RawRepresentable, Hashable where AllCases == [Self], RawValue == String {
    /// The type of value associated with the key.
    associatedtype Value
    /// The key path to the associated value in the environment.
    static var keyPath: WritableKeyPath<EnvironmentValues, Value> { get }
    /// The default selection for the key.
    static var defaultCase: Self { get }
    /// The default description for the key.
    static var defaultDescription: String { get }
    /// The current value associated with the key.
    var value: Value { get }
}

/// Provides a default implementation for `defaultValue` to use the first case.
public extension DynamicValueKey {
    static var defaultCase: Self {
        if let first = allCases.first { return first }
        fatalError("DynamicValueKey requires at least one case")
    }

    static var defaultDescription: String {
        String(describing: Self.self).addingSpacesToCamelCase()
    }
}

/// A preference key for storing dynamic value entries.
/// This key allows for the aggregation of menu items to be displayed in a custom menu.
struct DynamicValuePreferenceKey: PreferenceKey {
    /// The default value for the menu content.
    static var defaultValue: [DynamicValueEntry] = []

    /// Combines the current value with the next value.
    static func reduce(value: inout [DynamicValueEntry], nextValue: () -> [DynamicValueEntry]) {
        value.append(contentsOf: nextValue())
    }
}

public extension DynamicValueSelectorStyle where Self == DynamicValueSheetPresentation {
    static func sheet(isPresented: Binding<Bool>) -> Self {
        .init(isPresenting: isPresented)
    }
}

/// Defines static presentation detents for menu sizes.
@available(iOS 16.4, *)
extension PresentationDetent {
    enum DynamicValueSelector {
        /// A detent representing an expanded menu.
        static let expanded = PresentationDetent.fraction(1/2)
        /// A detent representing a compact menu.
        static let compact = PresentationDetent.fraction(1/4)
    }
}

/// A view modifier that adds a custom expandable menu to a SwiftUI view.
/// This modifier tracks and displays menu items dynamically added to the view,
/// providing a customizable and interactive menu experience.
public struct DynamicValueSheetPresentation: DynamicValueSelectorStyle {
    /// Indicates whether the menu is expanded.
    @Binding var presenting: Bool

    public init(isPresenting: Binding<Bool>) {
        _presenting = isPresenting
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topTrailing) {
                if !configuration.isEmpty {
                    HStack(spacing: .zero) {
                        Button {
                            withAnimation(.interactiveSpring) {
                                presenting.toggle()
                            }
                        } label: {
                            Image(systemName: presenting ? "xmark.circle" : "gear")
                                .rotationEffect(.degrees(presenting ? 180 : 0))
                                .font(.title2)
                                .frame(width: 24, height: 24)
                        }
                    }
                    .padding()
                }
            }
            .animation(.snappy, value: presenting)
            .overlay {
                Spacer().sheet(isPresented: $presenting) {
                    List {
                        configuration.entries
                    }
                    .padding([.top, .horizontal])
                    .listStyle(.plain)
                    .blendMode(.multiply)
                    .menuPresentationDetents()
                    .hideScrollContentBackground()
                }
            }
    }
}

public extension DynamicValueSelectorStyle where Self == DynamicValueInlineStyle {
    static var inline: Self { .init() }
}

public struct DynamicValueInlineStyle: DynamicValueSelectorStyle {
    public func makeBody(configuration: Configuration) -> some View {
        ScrollView {
            VStack {
                configuration.entries
                configuration.content.padding(.top)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollBounceBehavior(.basedOnSize)
    }
}

public extension DynamicValueSelectorStyle where Self == DynamicValueContextMenuStyle {
    static var contextMenu: Self { .init() }
}

public struct DynamicValueContextMenuStyle: DynamicValueSelectorStyle {
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content.contextMenu {
            configuration.entries
        }
    }
}

public protocol DynamicValueSelectorStyle {
    associatedtype Body: View
    typealias Configuration = DynamicValueSelectorStyleConfiguration
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

private struct DynamicValueSelectorStyleKey: EnvironmentKey {
    static let defaultValue: any DynamicValueSelectorStyle = DynamicValueInlineStyle()
}

extension EnvironmentValues {
    var selectorStyle: any DynamicValueSelectorStyle {
        get { self[DynamicValueSelectorStyleKey.self] }
        set { self[DynamicValueSelectorStyleKey.self] = newValue }
    }
}

// MARK: - Configuration

public struct DynamicValueSelectorStyleConfiguration {
    public typealias Content = AnyView
    public typealias Entries = ForEach<[DynamicValueEntry], DynamicValueEntry.ID, AnyView>
    public let content: Content
    public let isEmpty: Bool
    public let entries: Entries
}

public struct DynamicValueSelector<Content: View>: View {
    let content: Content
    let title: LocalizedStringKey
    @State private var data: [DynamicValueEntry] = []
    @Environment(\.selectorStyle) private var style

    public init(
        title: LocalizedStringKey = "Settings",
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    private var configuration: DynamicValueSelectorStyle.Configuration {
        .init(
            content: .init(content),
            isEmpty: data.isEmpty,
            entries: .init(data, content: { $0.view })
        )
    }

    public var body: some View {
        AnyView(style.makeBody(configuration: configuration))
            .onPreferenceChange(DynamicValuePreferenceKey.self) { newValue in
                data = newValue
            }
    }
}

private extension View {
    @ViewBuilder func menuPresentationDetents() -> some View {
        if #available(iOS 16.4, *) {
            presentationDetents([
                .DynamicValueSelector.compact,
                .DynamicValueSelector.expanded
            ])
            .presentationBackgroundInteraction(.enabled)
            .presentationContentInteraction(.resizes)
            .presentationCornerRadius(24)
            .presentationBackground(.ultraThinMaterial)
        }
        else {
            self
        }
    }
}

private extension View {
    @ViewBuilder func hideScrollContentBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.edgesIgnoringSafeArea(.top)
                .listRowBackground(EmptyView())
                .scrollContentBackground(.hidden)
        }
        else {
            self
        }
    }
}

/// Represents a view that can be uniquely identified and compared for equality.
/// This allows views to be managed and manipulated within collections, such as menus.
public struct DynamicValueEntry: Identifiable, Equatable {
    /// Enables comparison between instances of `MenuEntry`.
    public static func == (lhs: DynamicValueEntry, rhs: DynamicValueEntry) -> Bool {
        lhs.id == rhs.id
    }

    /// A unique identifier for the view.
    public let id: UUID
    /// The view being managed.
    let view: AnyView
    /// The view type managed.
    let viewType: String
    /// Initializes a new instance with a specific view and an optional identifier.
    /// - Parameters:
    ///   - view: The view to be managed.
    ///   - id: An optional unique identifier. A new UUID is generated if not provided.
    init<V: View>(_ view: V, id: UUID = UUID()) {
        self.view = AnyView(view)
        self.viewType = String(describing: V.self)
        self.id = id
    }
}
