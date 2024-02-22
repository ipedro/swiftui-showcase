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
///             .environmentPickerValue(MyDynamicKey.self)
///     }
/// }
/// ```
///
/// - Requires: `Key` conforming to `EnvironmentPickerKey` protocol.
struct EnvironmentPickerContainer<Key>: ViewModifier where Key: EnvironmentPickerKey {
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
            .background(
                GeometryReader { _ in
                    Color.clear.preference(
                        key: EnvironmentPickerPreferenceKey.self,
                        value: [.init(selection: $store.selection)]
                    )
                }
            )
    }
}

/// An extension on `View` to apply the `EnvironmentPickerContainer` modifier.
///
/// This extension allows any SwiftUI view to dynamically select and apply environment values
/// using a specified key conforming to `EnvironmentPickerKey`.
public extension View {
    /// Applies a dynamic value selector to the view based on the specified key.
    ///
    /// - Parameter key: The type of the dynamic value key.
    /// - Returns: A view modified to dynamically select and apply an environment value.
    func environmentPickerValue<Key: EnvironmentPickerKey>(_ key: Key.Type) -> some View {
        modifier(EnvironmentPickerContainer(key))
    }
}

public extension View {
    /// Applies a dynamic value selector to the view.
    /// - Parameter key: The type of the dynamic value key.
    /// - Returns: A view modified to select and apply a dynamic environment value based on the given key.
    func environmentPickerStyle<S: EnvironmentPickerStyle>(_ style: S) -> some View {
        environment(\.style, style)
    }
}
/// Defines the requirements for keys used with dynamic environment values in SwiftUI.
///
/// Conforming types can dynamically select and apply values to the SwiftUI environment,
/// enabling customizable and responsive UI components.
public protocol EnvironmentPickerKey: CaseIterable, RawRepresentable, Hashable where AllCases == [Self], RawValue == String {
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

/// Provides default implementations for the `EnvironmentPickerKey` protocol,
/// ensuring a minimal configuration is required for conforming types.
public extension EnvironmentPickerKey {
    /// Returns the first case as the default selection if available, otherwise triggers a runtime error.
    static var defaultCase: Self {
        guard let first = allCases.first else {
            fatalError("EnvironmentPickerKey requires at least one case")
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
struct EnvironmentPickerPreferenceKey: PreferenceKey {
    /// The default value for the dynamic value entries.
    static var defaultValue: [EnvironmentPickerEntry] = []

    /// Combines the current value with the next value.
    ///
    /// - Parameters:
    ///   - value: The current value of dynamic value entries.
    ///   - nextValue: A closure that returns the next set of dynamic value entries.
    static func reduce(value: inout [EnvironmentPickerEntry], nextValue: () -> [EnvironmentPickerEntry]) {
        value.append(contentsOf: nextValue())
    }
}

@available(macOS 12.0, *)
public extension EnvironmentPickerStyle where Self == SheetEnvironmentPicker {
    static func sheet(isPresented: Binding<Bool>) -> Self {
        .init(isPresenting: isPresented)
    }
}

/// Defines static presentation detents for menu sizes.
@available(iOS 16.4, macOS 13.0, *)
extension PresentationDetent {
    enum EnvironmentPicker {
        /// A detent representing an expanded menu.
        static let expanded = PresentationDetent.fraction(1/2)
        /// A detent representing a compact menu.
        static let compact = PresentationDetent.fraction(1/4)
    }
}

/// A view modifier that adds a custom expandable menu to a SwiftUI view.
/// This modifier tracks and displays menu items dynamically added to the view,
/// providing a customizable and interactive menu experience.
@available(macOS 12.0, *)
public struct SheetEnvironmentPicker: EnvironmentPickerStyle {
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

// MARK: - EnvironmentPickerStyle Protocol Extensions

/// Provides a convenient static property for accessing the inline selector style.
public extension EnvironmentPickerStyle where Self == InlineEnvironmentPicker {
    /// A static property to access an inline selector style instance.
    static var inline: Self { .init() }
}

/// A style that presents dynamic value options inline within the view hierarchy.
public struct InlineEnvironmentPicker: EnvironmentPickerStyle {
    /// Creates the view for the inline style, embedding the dynamic value options directly within a scrollable area.
    ///
    /// - Parameter configuration: The configuration containing the dynamic value options and content.
    /// - Returns: A view displaying the dynamic value options inline.
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

/// A private extension to View to customize the scroll bounce behavior based on the iOS version.
private extension View {
    /// Applies scroll bounce behavior based on the size for iOS 16.4 and later; otherwise, does nothing.
    @ViewBuilder func scrollBounceBehaviorBasedOnSize() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            scrollBounceBehavior(.basedOnSize)
        } else {
            self
        }
    }
}

/// Provides a convenient static property for accessing the context menu selector style.
public extension EnvironmentPickerStyle where Self == ContextMenuEnvironmentPicker {
    /// A static property to access a context menu selector style instance.
    static var contextMenu: Self { .init() }
}

/// A style that presents dynamic value options within a context menu.
public struct ContextMenuEnvironmentPicker: EnvironmentPickerStyle {
    /// Creates the view for the context menu style, presenting the dynamic value options within a context menu.
    ///
    /// - Parameter configuration: The configuration containing the dynamic value options and content.
    /// - Returns: A view displaying the dynamic value options in a context menu.
    public func makeBody(configuration: Configuration) -> some View {
        configuration.content.contextMenu {
            configuration.entries
        }
    }
}

// MARK: - EnvironmentPickerStyle Protocol

/// A protocol for defining custom styles for presenting dynamic value selectors.
public protocol EnvironmentPickerStyle {
    /// The associated type representing the body of the selector style.
    associatedtype Body: View

    /// A typealias for the configuration used by the selector style.
    typealias Configuration = EnvironmentPickerStyleConfiguration

    /// Creates the body of the selector style using the provided configuration.
    ///
    /// - Parameter configuration: The configuration for the selector style.
    /// - Returns: A view representing the body of the selector style.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

// MARK: - Environment Key for Picker Style

/// An environment key for storing the current dynamic value selector style.
private struct EnvironmentPickerStyleKey: EnvironmentKey {
    /// The default value for the selector style, using `EnvironmentPickerInlineStyle` as the default.
    static let defaultValue: any EnvironmentPickerStyle = InlineEnvironmentPicker()
}

/// Extends `EnvironmentValues` to include a property for accessing the dynamic value selector style.
extension EnvironmentValues {
    /// The current dynamic value selector style within the environment.
    var style: any EnvironmentPickerStyle {
        get { self[EnvironmentPickerStyleKey.self] }
        set { self[EnvironmentPickerStyleKey.self] = newValue }
    }
}

// MARK: - Configuration for Picker Styles

/// Represents the configuration for dynamic value selector styles, encapsulating the content and dynamic value entries.
public struct EnvironmentPickerStyleConfiguration {
    /// The content to be presented alongside the dynamic value entries.
    public typealias Content = AnyView
    /// The actual content view.
    public let content: Content
    /// A boolean indicating if there are no dynamic value entries.
    public let isEmpty: Bool
    /// The dynamic value entries to be presented.
    public let entries: Entries

    /// Represents the dynamic value entries within the selector.
    public struct Entries: View {
        /// The data for each dynamic value entry.
        let data: [EnvironmentPickerEntry]

        /// Creates the view for each dynamic value entry, typically as a picker.
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

// MARK: - EnvironmentPicker View

/** 

 A SwiftUI view for presenting dynamic value selectors using the specified style.

 # Dynamic SwiftUI Environment Values

 SwiftUI provides a powerful and flexible framework for building user interfaces. A key feature of SwiftUI is its ability to   dynamically adapt UI components based on environment values. This package enhances this capability by introducing a robust system for dynamically selecting environment values through custom view modifiers and selector styles.

 ## Overview

 This package offers a suite of tools to facilitate the customization and dynamic updating of UI components in SwiftUI based on selected environment values. It leverages SwiftUI's environment, `ObservableObject`, and `PreferenceKey` to create a responsive and customizable interface.

 ### Key Features

 - **Dynamic Value Selection**: Dynamically select environment values with an extendable protocol-based approach.
 - **Customizable Picker Styles**: Implement custom selector styles to provide unique UI elements for value selection.
 - **Advanced State Management**: Utilize `ObservableObject` for managing selections, enhancing reactivity and performance.

 ## Getting Started

 To start using this package, integrate it into your SwiftUI project and follow the steps below to implement dynamic value selection in your views.

 ### EnvironmentPickerContent Modifier

 The `EnvironmentPickerContent` view modifier applies dynamic environment values to SwiftUI views. This modifier uses a generic `Key` parameter conforming to the `EnvironmentPickerKey` protocol to identify the specific environment value to modify.

 #### Example Usage

 ```swift
 struct ContentView: View {
     var body: some View {
         Text("Hello, Dynamic World!")
             .environmentPickerValue(MyDynamicKey.self)
     }
 }
 ```

 ### Defining Dynamic Keys

 To define dynamic keys, conform to the `EnvironmentPickerKey` protocol. This protocol requires specifying a `keyPath`, `defaultCase`, and associated value type.

 ```swift
 enum MyDynamicKey: String, EnvironmentPickerKey {
     case optionOne, optionTwo

     static var keyPath: WritableKeyPath<EnvironmentValues, String> {
         \.myEnvironmentPicker
     }

     static var defaultCase: Self {
         .optionOne
     }

     var value: String {
         switch self {
         case .optionOne: return "Option One"
         case .optionTwo: return "Option Two"
         }
     }
 }
 ```

 ### Custom Picker Styles

 This package introduces a `EnvironmentPickerStyle` protocol to create customizable selector styles. Implement this protocol to define custom UI elements for selecting dynamic values.

 #### Example: Inline Style

 ```swift
 struct InlinePickerStyle: EnvironmentPickerStyle {
     // Implementation details...
 }
 ```

 Apply your custom style using the `environmentPickerStyle` modifier:

 ```swift
 Text("Select Option")
     .environmentPickerStyle(InlinePickerStyle())
 ```

 ## Advanced Usage

 ### Handling Selection Changes

 To respond to changes in the selected dynamic value, use the `@ObservedObject` or `@EnvironmentObject` property wrappers to observe the `EnvironmentPickerManager` object.

 ### Extending Picker Styles

 Extend the `EnvironmentPickerStyle` protocol to create sophisticated selector UIs, such as context menus or custom popovers. This approach encourages modular design and reusability.

 */
public struct EnvironmentPicker<Content: View>: View {
    /// The content to be presented alongside the dynamic value selector.
    let content: Content
    /// The state holding the dynamic value entries.
    @State private var data: [EnvironmentPickerEntry] = []
    /// The current dynamic value selector style from the environment.
    @Environment(\.style) private var style

    /// Initializes the dynamic value selector with the specified content and optional title.
    ///
    /// - Parameters:
    ///   - content: A closure returning the content to be presented.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    /// Creates the configuration for the selector style and presents the content accordingly.
    private var configuration: EnvironmentPickerStyle.Configuration {
        .init(
            content: .init(content),
            isEmpty: data.isEmpty,
            entries: .init(data: data)
        )
    }

    /// The body of the dynamic value selector, presenting the content using the current selector style.
    public var body: some View {
        AnyView(style.makeBody(configuration: configuration))
            .onPreferenceChange(EnvironmentPickerPreferenceKey.self) { newValue in
                data = newValue
            }
    }
}

// MARK: - Helper Extensions for View Presentation

/// A private extension to View for customizing the presentation detents of a menu.
private extension View {
    /// Applies presentation detents to the view for iOS 16.4 and later; otherwise, does nothing.
    @ViewBuilder func menuPresentationDetents() -> some View {
        if #available(iOS 16.4, macOS 13.3, *) {
            presentationDetents([
                .EnvironmentPicker.compact,
                .EnvironmentPicker.expanded
            ])
            .presentationBackgroundInteraction(.enabled)
            .presentationContentInteraction(.resizes)
            .presentationCornerRadius(24)
            .presentationBackground(.ultraThinMaterial)
        } else {
            self
        }
    }
}

/// A private extension to View for hiding the scroll content background.
private extension View {
    /// Hides the scroll content background for iOS 16.0 and later; otherwise, does nothing.
    @ViewBuilder func hideScrollContentBackground() -> some View {
        if #available(iOS 16.0, macOS 13.0, *) {
            self.edgesIgnoringSafeArea(.top)
                .listRowBackground(EmptyView())
                .scrollContentBackground(.hidden)
        } else {
            self
        }
    }
}

/// Represents a dynamic value entry with a unique identifier, title, and selectable options.
struct EnvironmentPickerEntry: Identifiable, Equatable {
    /// A unique identifier for the entry.
    let id = UUID()
    /// The title of the entry, used as a label in the UI.
    let title: String
    /// A binding to the currently selected option.
    let selection: Binding<String>
    /// The options available for selection.
    let options: [String]

    /// Initializes a new dynamic value entry with the specified parameters.
    ///
    /// - Parameters:
    ///   - key: The dynamic value key type.
    ///   - selection: A binding to the currently selected key.
    init<Key: EnvironmentPickerKey>(_ key: Key.Type = Key.self, selection: Binding<Key>) {
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

    /// Determines if two entries are equal based on their identifiers.
    static func == (lhs: EnvironmentPickerEntry, rhs: EnvironmentPickerEntry) -> Bool {
        lhs.id == rhs.id
    }
}

/// Extension to `String` for improving readability of camelCase strings by adding spaces.
private extension String {
    /// Adds spaces before each uppercase letter in a camelCase string.
    ///
    /// Usage:
    ///
    /// ```swift
    /// let camelCaseString = "environmentPickerKey"
    /// let readableString = camelCaseString.addingSpacesToCamelCase()
    /// // readableString is "dynamic Value Key"
    /// ```
    ///
    /// - Returns: A new string with spaces added before each uppercase letter.
    func addingSpacesToCamelCase() -> String {
        self.replacingOccurrences(of: "(?<=[a-z])(?=[A-Z])", with: " $0", options: .regularExpression, range: self.range(of: self))
    }
}
