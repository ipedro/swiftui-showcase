// Copyright (c) 2023 Pedro Almeida
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

/// A type that applies standard interaction behavior and a custom appearance to
/// all Showcases within a view hierarchy.
///
/// To configure the current Showcase style for a view hierarchy, use the
/// ``Showcase/showcaseExternalLinkStyle(_:)`` modifier.

// MARK: - View Extension

extension View {
    /// Sets the style for ``Showcase`` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for ``Showcase`` instances
    /// within a view:
    ///
    ///     Showcase()
    ///         .showcaseExternalLinkStyle(MyCustomStyle())
    ///
    public func showcaseExternalLinkStyle<S: ButtonStyle>(_ style: S) -> some View {
        environment(\.externalLinkStyle, .init(style))
    }
}


// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct ExternalLinkStyleKey: EnvironmentKey {
    static var defaultValue: AnyButtonStyle = .init(.standard)
    static func reduce(value: inout AnyButtonStyle, nextValue: () -> AnyButtonStyle) {}
}

extension EnvironmentValues {
    /// The current Showcase style value.
    var externalLinkStyle: AnyButtonStyle {
        get { self[ExternalLinkStyleKey.self] }
        set { self[ExternalLinkStyleKey.self] = newValue }
    }
}
