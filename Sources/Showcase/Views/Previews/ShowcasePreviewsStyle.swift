import SwiftUI

/// A type that applies standard interaction behavior and a custom appearance to
/// all Showcases within a view hierarchy.
///
/// To configure the current Showcase style for a view hierarchy, use the
/// ``Showcase/showcasePreviewsStyle(_:)`` modifier.
public protocol ShowcasePreviewsStyle {
    /// A view that represents the body of a Showcase.
    associatedtype Body: View

    /// The properties of a Showcase.
    typealias Configuration = ShowcasePreviewsStyleConfiguration

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
    ///         .showcasePreviewsStyle(MyCustomStyle())
    ///
    public func showcasePreviewsStyle<S: ShowcasePreviewsStyle>(_ style: S) -> some View {
        environment(\.previewsStyle, .init(style))
    }
}

// MARK: - Type Erasure

public extension ShowcasePreviewsStyle {
    /// Returns a type erased Showcase.
    func asAny() -> AnyShowcasePreviewsStyle { .init(self) }
}

/// A type erased Showcase style.
public struct AnyShowcasePreviewsStyle: ShowcasePreviewsStyle {
    /// Current Showcase style.
    var style: any ShowcasePreviewsStyle
   
    /// Creates a type erased Showcase style.
    public init<S: ShowcasePreviewsStyle>(_ style: S) {
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct ShowcasePreviewsStyleKey: EnvironmentKey {
    static var defaultValue: AnyShowcasePreviewsStyle = .init(.paged)
    static func reduce(value: inout AnyShowcasePreviewsStyle, nextValue: () -> AnyShowcasePreviewsStyle) {}
}

extension EnvironmentValues {
    /// The current Showcase style value.
    public var previewsStyle: AnyShowcasePreviewsStyle {
        get { self[ShowcasePreviewsStyleKey.self] }
        set { self[ShowcasePreviewsStyleKey.self] = newValue }
    }
}
