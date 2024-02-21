import SwiftUI

/// A view modifier that dynamically selects environment values for SwiftUI views.
/// This allows views to adapt their appearance or behavior based on selected values,
/// facilitating customization and dynamic UI updates.
struct DynamicValueContent<Key>: ViewModifier where Key: DynamicValueKey {
    /// The key type that identifies the dynamic value.
    let key: Key.Type

    // Simplify the dynamic value management by using ObservableObject for global state management.
    private class Store: ObservableObject {
        @Published var selection = Key.defaultSelection
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
                        key: DynamicValueEntryPreferenceKey.self,
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
extension View {
    /// Applies a dynamic value selector to the view.
    /// - Parameter key: The type of the dynamic value key.
    /// - Returns: A view modified to select and apply a dynamic environment value based on the given key.
    func dynamicValue<Key: DynamicValueKey>(_ key: Key.Type) -> some View {
        modifier(DynamicValueContent(key))
    }
}

/// A protocol defining the requirements for keys used with dynamic environment values.
/// Types conforming to this protocol can be used to dynamically select and apply values to the SwiftUI environment.
public protocol DynamicValueKey: RawRepresentable, CaseIterable, Hashable where RawValue == String, AllCases == [Self] {
    /// The type of value associated with the key.
    associatedtype Value
    /// The key path to the associated value in the environment.
    static var keyPath: WritableKeyPath<EnvironmentValues, Value> { get }
    /// The default selection for the key.
    static var defaultSelection: Self { get }
    /// The default description for the key.
    static var defaultDescription: String { get }
    /// The current value associated with the key.
    var value: Value { get }
}

/// Provides a default implementation for `defaultSelection` to use the first case.
public extension DynamicValueKey {
    static var defaultSelection: Self {
        if let first = allCases.first { return first }
        fatalError("DynamicValueKey requires at least one case")
    }

    static var defaultDescription: String {
        String(describing: Self.self).addingSpacesToCamelCase()
    }
}

/// A preference key for storing dynamic value entries.
/// This key allows for the aggregation of menu items to be displayed in a custom menu.
struct DynamicValueEntryPreferenceKey: PreferenceKey {
    /// The default value for the menu content.
    static var defaultValue: [DynamicValueEntry] = []

    /// Combines the current value with the next value.
    static func reduce(value: inout [DynamicValueEntry], nextValue: () -> [DynamicValueEntry]) {
        value.append(contentsOf: nextValue())
    }
}

/// Defines static presentation detents for menu sizes.
@available(iOS 16.4, *)
private extension PresentationDetent {
    /// A detent representing an expanded menu.
    static var menuExpandedDetent: Self { .fraction(1/2) }
    /// A detent representing a compact menu.
    static var menuCompactDetent: Self  { .fraction(1/4) }
}

public extension View {
    /// Applies an expandable menu wrapper to the view.
    ///
    /// This convenience function wraps the view within an `DynamicValuePresentationModifier` view modifier,
    /// enabling the display of a custom, dynamic menu based on user interactions. The menu can be expanded
    /// or collapsed, and it adapts to content changes dynamically, providing a flexible way to present
    /// additional options or settings.
    ///
    /// Example usage:
    /// ```
    /// Text("Hello, World!")
    ///     .applyExpandableMenu()
    /// ```
    ///
    /// - Returns: A view modified to include an expandable menu, utilizing the `DynamicValuePresentationModifier`.
    func dynamicValueSelectorSheet(isPresenting: Binding<Bool>) -> some View {
        modifier(
            DynamicValueSheetPresenter(presenting: isPresenting)
        )
    }

    func dynamicValueSelector() -> some View {
        modifier(
            DynamicValueSelectionModifier()
        )
    }
}

/// A view modifier that adds a custom expandable menu to a SwiftUI view.
/// This modifier tracks and displays menu items dynamically added to the view,
/// providing a customizable and interactive menu experience.
struct DynamicValueSheetPresenter: ViewModifier {
    /// Indicates whether the menu is expanded.
    @Binding var presenting: Bool
    /// The collection of menu items to display.
    @State private var menuItems: [DynamicValueEntry] = []
    /// Computes the bottom safe area inset based on the menu's expansion state and detent.
    @State private var bottomSafeAreaInset: CGFloat = 0

    /// The content and behavior of the view.
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(DynamicValueEntryPreferenceKey.self) { items in
                menuItems = items
            }
            .safeAreaInset(edge: .bottom, spacing: .zero) {
                Spacer().frame(height: bottomSafeAreaInset)
            }
            .overlay(alignment: .topTrailing) {
                if !menuItems.isEmpty {
                    HStack(spacing: .zero) {
                        Button {
                            withAnimation(.interactiveSpring) {
                                presenting.toggle()
                            }
                        } label: {
                            Image(systemName: presenting ? "xmark.circle" : "gear")
                                .rotationEffect(.degrees(presenting ? 180 : 0))
                                .font(.title2)
                                .frame(
                                    width: 24,
                                    height: 24
                                )
                        }
                    }
                    .padding()
                }
            }
            .animation(.snappy, value: presenting)
            .overlay {
                Spacer().sheet(isPresented: $presenting) {
                    GeometryReader { geometry in
                        DynamicValueSelectionList(
                            title: "Preview Settings",
                            data: menuItems.reversed()
                        )
                        .blendMode(.multiply)
                        .menuPresentationDetents()
                        .onChange(of: geometry.size, perform: { size in
                            bottomSafeAreaInset = size.height
                        })
                    }
                }
            }
    }
}

/// A type that applies standard interaction behavior and a custom appearance.
//public protocol DynamicValueSelectorStyle {
//    /// A view that represents the body of a Card.
//    associatedtype Body: View
//
//    /// The properties of a Card.
//    typealias Configuration = DynamicValueSelectorStyleConfiguration
//
//    /// Creates a view that represents the body of a dynamic value picker.
//    @ViewBuilder func makeBody(configuration: Configuration) -> Body
//}

// MARK: - Configuration

/// The state and subviews of a Card.
//public struct DynamicValueSelectorStyleConfiguration {
//    public let label: AnyView
//    public let entries
//
//    public struct Entry: {
//
//    }
//}

//public struct DynamicValueSelector<Label: View>: View {
//    /// The collection of menu items to display.
//    var label: Label
//    @State private var data: [DynamicValueEntry] = []
//
//    init(@ViewBuilder label: () -> Label) {
//        self.label = label()
//    }
//
//    public var body: some View {
//        VStack {
//            label
//
//            DynamicValueSelectionList(
//                title: "Preview Settings",
//                data: data.reversed()
//            )
//        }
//        .onPreferenceChange(DynamicValueEntryPreferenceKey.self) { items in
//            data = items
//        }
//    }
//}

struct DynamicValueSelectionModifier: ViewModifier {
    /// The collection of menu items to display.
    @State private var data: [DynamicValueEntry] = []

    /// The content and behavior of the view.
    func body(content: Content) -> some View {
        VStack {
            content

            DynamicValueSelectionList(
                title: "Preview Settings",
                data: data.reversed()
            )
        }
        .onPreferenceChange(DynamicValueEntryPreferenceKey.self) { items in
            data = items
        }
    }
}

private extension View {
    @ViewBuilder func menuPresentationDetents() -> some View {
        if #available(iOS 16.4, *) {
            self.presentationDetents([.menuCompactDetent, .menuExpandedDetent])
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

struct DynamicValueSelectionList: View {
    let title: LocalizedStringKey
    let data: [DynamicValueEntry]

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.top, 20)
                .frame(maxWidth: .infinity)

            List {
                ForEach(data) { item in
                    item.view.padding(.horizontal)
                }
            }
            .listStyle(.plain)
            .hideScrollContentBackground()
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
struct DynamicValueEntry: Identifiable, Equatable {
    /// Enables comparison between instances of `MenuEntry`.
    static func == (lhs: DynamicValueEntry, rhs: DynamicValueEntry) -> Bool {
        lhs.id == rhs.id
    }

    /// A unique identifier for the view.
    let id: UUID
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
