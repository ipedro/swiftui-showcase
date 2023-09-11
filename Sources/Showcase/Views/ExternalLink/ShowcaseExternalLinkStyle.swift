import SwiftUI

/// A type that applies standard interaction behavior and a custom appearance to
/// all Showcases within a view hierarchy.
///
/// To configure the current Showcase style for a view hierarchy, use the
/// ``Showcase/externalLinkStyle(_:)`` modifier.
public protocol ShowcaseExternalLinkStyle: PrimitiveButtonStyle {
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
    ///         .externalLinkStyle(MyCustomStyle())
    ///
    public func showcaseExternalLinkStyle<S: ShowcaseExternalLinkStyle>(_ style: S) -> some View {
        environment(\.externalLinkStyle, .init(style))
    }
}

// MARK: - Type Erasure

public extension ShowcaseExternalLinkStyle {
    /// Returns a type erased Showcase.
    func asAny() -> AnyShowcaseExternalLinkStyle { .init(self) }
}

/// A type erased Showcase style.
public struct AnyShowcaseExternalLinkStyle: ShowcaseExternalLinkStyle {
    /// Current Showcase style.
    var style: any ShowcaseExternalLinkStyle
   
    /// Creates a type erased Showcase style.
    public init<S: ShowcaseExternalLinkStyle>(_ style: S) {
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct ExternalLinkStyleKey: EnvironmentKey {
    static var defaultValue: AnyShowcaseExternalLinkStyle = .init(.standard)
    static func reduce(value: inout AnyShowcaseExternalLinkStyle, nextValue: () -> AnyShowcaseExternalLinkStyle) {}
}

extension EnvironmentValues {
    /// The current Showcase style value.
    public var externalLinkStyle: AnyShowcaseExternalLinkStyle {
        get { self[ExternalLinkStyleKey.self] }
        set { self[ExternalLinkStyleKey.self] = newValue }
    }
}
