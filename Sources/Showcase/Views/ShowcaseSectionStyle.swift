import SwiftUI

/// A type that applies standard interaction behavior and a custom appearance to
/// all Showcases within a view hierarchy.
///
/// To configure the current Showcase style for a view hierarchy, use the
/// ``Showcase/ShowcaseSectionStyle(_:)`` modifier.
public protocol ShowcaseSectionStyle {
    /// A view that represents the body of a Showcase.
    associatedtype Body: View

    /// The properties of a Showcase.
    typealias Configuration = ShowcaseSectionStyleConfiguration

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
    ///     HStack {
    ///         Showcase()
    ///         Showcase()
    ///     }
    ///     .showcaseSectionStyle(.example)
    ///
    public func showcaseSectionStyle<S: ShowcaseSectionStyle>(_ style: S) -> some View {
        environment(\.showcaseSectionStyle, .init(style))
    }
}

// MARK: - Type Erasure

public extension ShowcaseSectionStyle {
    /// Returns a type erased Showcase.
    func asAny() -> AnyShowcaseSectionStyle { .init(self) }
}

/// A type erased Showcase style.
public struct AnyShowcaseSectionStyle: ShowcaseSectionStyle {
    /// Current Showcase style.
    var style: any ShowcaseSectionStyle
   
    /// Creates a type erased Showcase style.
    public init<S: ShowcaseSectionStyle>(_ style: S) {
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct ShowcaseSectionStyleKey: EnvironmentKey {
    static var defaultValue: AnyShowcaseSectionStyle = .init(.system)
    static func reduce(value: inout AnyShowcaseSectionStyle, nextValue: () -> AnyShowcaseSectionStyle) {}
}

extension EnvironmentValues {
    /// The current Showcase style value.
    public var showcaseSectionStyle: AnyShowcaseSectionStyle {
        get { self[ShowcaseSectionStyleKey.self] }
        set { self[ShowcaseSectionStyleKey.self] = newValue }
    }
}
