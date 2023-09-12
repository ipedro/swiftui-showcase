import SwiftUI

/// A type erased Showcase style.
struct AnyButtonStyle: ButtonStyle {
    /// Current Showcase style.
    var style: any ButtonStyle
   
    /// Creates a type erased Showcase style.
    public init<S: ButtonStyle>(_ style: S) {
        self.style = style
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

extension ButtonStyle {
    /// Returns a type erased Showcase.
    func asAny() -> AnyButtonStyle { .init(self) }
}
