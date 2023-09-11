import SwiftUI

/// A type that applies standard interaction behavior and a custom appearance to
/// all Showcases within a view hierarchy.
///
/// To configure the current Showcase style for a view hierarchy, use the
/// ``Showcase/showcaseStyle(_:)`` modifier.
public protocol ShowcaseStyle {
    /// A view that represents the body of a Showcase.
    associatedtype Body: View

    /// The properties of a Showcase.
    typealias Configuration = ShowcaseStyleConfiguration

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
    /// Sets the style for Showcase within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for Showcase instances
    /// within a view:
    ///
    ///     Showcase(element)
    ///         .showcaseStyle(.standard)
    ///
    public func showcaseStyle<S: ShowcaseStyle>(_ style: S) -> some View {
        environment(\.showcaseStyle, .init(style))
    }
}

// MARK: - Type Erasure

public extension ShowcaseStyle {
    /// Returns a type erased Showcase.
    func asAny() -> AnyShowcaseStyle { .init(self) }
}

/// A type erased Showcase style.
public struct AnyShowcaseStyle: ShowcaseStyle {
    /// Current Showcase style.
    var style: any ShowcaseStyle
   
    /// Creates a type erased Showcase style.
    public init<S: ShowcaseStyle>(_ style: S) {
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct ShowcaseStyleKey: EnvironmentKey {
    static var defaultValue: AnyShowcaseStyle = .init(.standard)
    static func reduce(value: inout AnyShowcaseStyle, nextValue: () -> AnyShowcaseStyle) {}
}

extension EnvironmentValues {
    /// The current Showcase style value.
    public var showcaseStyle: AnyShowcaseStyle {
        get { self[ShowcaseStyleKey.self] }
        set { self[ShowcaseStyleKey.self] = newValue }
    }
}
