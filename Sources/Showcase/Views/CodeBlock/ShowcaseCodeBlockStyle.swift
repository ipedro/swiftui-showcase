import SwiftUI

/// A type that applies standard interaction behavior and a custom appearance to
/// all Showcases within a view hierarchy.
///
/// To configure the current Showcase style for a view hierarchy, use the
/// ``Showcase/showcaseCodeBlockStyle(_:)`` modifier.
public protocol ShowcaseCodeBlockStyle {
    /// A view that represents the body of a Showcase.
    associatedtype Body: View

    /// The properties of a Showcase.
    typealias Configuration = ShowcaseCodeBlockStyleConfiguration

    /// Creates a view that represents the body of a Showcase.
    ///
    /// The system calls this method for each ``Showcase`` instance in a view
    /// hierarchy where this style is the current Showcase style.
    ///
    /// - Parameter configuration: The properties of a Showcase.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

// MARK: - View Extension

extension View {
    /// Sets the style for ``Showcase`` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for ``Showcase`` instances
    /// within a view:
    ///
    ///     Showcase()
    ///         .showcaseCodeBlockStyle(MyCustomStyle())
    ///
    public func showcaseCodeBlockStyle<S: ShowcaseCodeBlockStyle>(_ style: S) -> some View {
        environment(\.snippetStyle, .init(style))
    }
}

// MARK: - Type Erasure

public extension ShowcaseCodeBlockStyle {
    /// Returns a type erased Showcase.
    func asAny() -> AnyShowcaseCodeBlockStyle { .init(self) }
}

/// A type erased Showcase style.
public struct AnyShowcaseCodeBlockStyle: ShowcaseCodeBlockStyle {
    /// Current Showcase style.
    var style: any ShowcaseCodeBlockStyle
   
    /// Creates a type erased Showcase style.
    public init<S: ShowcaseCodeBlockStyle>(_ style: S) {
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct ShowcaseCodeBlockStyleKey: EnvironmentKey {
    static var defaultValue: AnyShowcaseCodeBlockStyle = .init(.standard)
    static func reduce(value: inout AnyShowcaseCodeBlockStyle, nextValue: () -> AnyShowcaseCodeBlockStyle) {}
}

extension EnvironmentValues {
    /// The current Showcase style value.
    public var snippetStyle: AnyShowcaseCodeBlockStyle {
        get { self[ShowcaseCodeBlockStyleKey.self] }
        set { self[ShowcaseCodeBlockStyleKey.self] = newValue }
    }
}
