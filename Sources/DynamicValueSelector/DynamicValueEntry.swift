import SwiftUI

/// A SwiftUI ViewModifier for dynamically selecting and applying environment values.
///
/// This ViewModifier leverages `ObservableObject` for state management, enabling dynamic
/// updates of SwiftUI views based on user-selected values. It is designed to facilitate
/// customization and enhance interactivity within the SwiftUI environment.
///
/// Usage:
///
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         Text("Hello, Dynamic World!")
///             .dynamicValue(MyDynamicKey.self)
///     }
/// }
/// ```
///
/// - Requires: `Key` conforming to `DynamicValueKey` protocol.
struct DynamicValueContent<Key>: ViewModifier where Key: DynamicValueKey {
    /// Identifies the dynamic value using a generic Key.
    let key: Key.Type

    /// Internal ObservableObject for managing the dynamic selection state.
    private class Store: ObservableObject {
        @Published var selection = Key.defaultCase
    }

    /// The current selection state of the dynamic value.
    @StateObject private var store = Store()

    /// Initializes the view modifier with a specific dynamic value key.
    ///
    /// - Parameter key: The type of the dynamic value key to use for selection.
    init(_ key: Key.Type) {
        self.key = key
    }

    /// Modifies the provided content view to dynamically apply selected environment values.
    ///
    /// - Parameter content: The original content view to modify.
    /// - Returns: A modified view with dynamic environment values applied.
    func body(content: Content) -> some View {
        content
            .environment(Key.keyPath, store.selection.value)
            .background {
                GeometryReader { _ in
                    Color.clear.preference(
                        key: DynamicValuePreferenceKey.self,
                        value: [.init(selection: $store.selection)]
                    )
                }
            }
    }
}

/// Extension to `String` for improving readability of camelCase strings by adding spaces.
private extension String {
    /// Adds spaces before each uppercase letter in a camelCase string.
    ///
    /// Usage:
    ///
    /// ```swift
    /// let camelCaseString = "dynamicValueKey"
    /// let readableString = camelCaseString.addingSpacesToCamelCase()
    /// // readableString is "dynamic Value Key"
    /// ```
    ///
    /// - Returns: A new string with spaces added before each uppercase letter.
    func addingSpacesToCamelCase() -> String {
        self.replacingOccurrences(of: "(?<=[a-z])(?=[A-Z])", with: " $0", options: .regularExpression, range: self.range(of: self))
    }
}

/// An extension on `View` to apply the `DynamicValueContent` modifier.
///
/// This extension allows any SwiftUI view to dynamically select and apply environment values
/// using a specified key conforming to `DynamicValueKey`.
public extension View {
    /// Applies a dynamic value selector to the view based on the specified key.
    ///
    /// - Parameter key: The type of the dynamic value key.
    /// - Returns: A view modified to dynamically select and apply an environment value.
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
/// Defines the requirements for keys used with dynamic environment values in SwiftUI.
///
/// Conforming types can dynamically select and apply values to the SwiftUI environment,
/// enabling customizable and responsive UI components.
public protocol DynamicValueKey: CaseIterable, RawRepresentable, Hashable where AllCases == [Self], RawValue == String {
    /// The associated value type for the dynamic key.
    associatedtype Value
    /// The key path to the associated value in the environment.
    static var keyPath: WritableKeyPath<EnvironmentValues, Value> { get }
    /// The default selection case for the key.
    static var defaultCase: Self { get }
    /// A user-friendly description for the key, improving UI readability.
    static var defaultDescription: String { get }
    /// The current value associated with the key.
    var value: Value { get }
}

/// Provides default implementations for the `DynamicValueKey` protocol,
/// ensuring a minimal configuration is required for conforming types.
public extension DynamicValueKey {
    /// Returns the first case as the default selection if available, otherwise triggers a runtime error.
    static var defaultCase: Self {
        guard let first = allCases.first else {
            fatalError("DynamicValueKey requires at least one case")
        }
        return first
    }

    /// Generates a user-friendly description by adding spaces before capital letters in the type name.
    static var defaultDescription: String {
        String(describing: Self.self).addingSpacesToCamelCase()
    }
}

/// A preference key for storing dynamic value entries.
///
/// This key aggregates values to be displayed in a custom selection menu, allowing
/// for dynamic updates and customization of menu content based on user selection.
struct DynamicValuePreferenceKey: PreferenceKey {
    /// The default value for the dynamic value entries.
    static var defaultValue: [DynamicValueEntry] = []

    /// Combines the current value with the next value.
    ///
    /// - Parameters:
    ///   - value: The current value of dynamic value entries.
    ///   - nextValue: A closure that returns the next set of dynamic value entries.
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
        .scrollBounceBehaviorBasedOnSize()
    }
}

private extension View {
    @ViewBuilder func scrollBounceBehaviorBasedOnSize() -> some View {
        if #available(iOS 16.4, *) {
            scrollBounceBehavior(.basedOnSize)
        }
        else {
            self
        }
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
    public let content: Content
    public let isEmpty: Bool
    public let entries: Entries

    public struct Entries: View {
        let data: [DynamicValueEntry]

        public var body: some View {
            ForEach(data) { entry in
                Picker(entry.title, selection: entry.selection) {
                    ForEach(entry.options, id: \.self) { item in
                        Text(item).tag(item)
                    }
                }
            }
        }
    }
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
            entries: .init(data: data)
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

struct DynamicValueEntry: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let selection: Binding<String>
    let options: [String]

    init<Key: DynamicValueKey>(_ key: Key.Type = Key.self, selection: Binding<Key>) {
        self.options = Key.allCases.map(\.rawValue)
        self.title = Key.defaultDescription
        self.selection = Binding {
            selection.wrappedValue.rawValue
        } set: { newValue in
            for aCase in Key.allCases where aCase.rawValue == newValue {
                selection.wrappedValue = aCase
            }
        }
    }

    static func == (lhs: DynamicValueEntry, rhs: DynamicValueEntry) -> Bool {
        lhs.id == rhs.id
    }
}
