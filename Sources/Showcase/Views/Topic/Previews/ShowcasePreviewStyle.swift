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
/// ``Showcase/showcasePreviewStyle(_:)`` modifier.
public protocol ShowcasePreviewStyle {
    /// A view that represents the body of a Showcase.
    associatedtype Body: View

    /// The properties of a Showcase.
    typealias Configuration = ShowcasePreviewStyleConfiguration

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
    ///         .showcasePreviewStyle(MyCustomStyle())
    ///
    public func showcasePreviewStyle<S: ShowcasePreviewStyle>(_ style: S) -> some View {
        environment(\.showcasePreviewStyle, .init(style))
    }
}

// MARK: - Type Erasure

/// A type erased Showcase style.
struct AnyShowcasePreviewStyle: ShowcasePreviewStyle {
    /// Current Showcase style.
    var style: any ShowcasePreviewStyle
   
    /// Creates a type erased Showcase style.
    init<S: ShowcasePreviewStyle>(_ style: S) {
        self.style = style
    }
    
    func makeBody(configuration: Configuration) -> some View {
        AnyView(style.makeBody(configuration: configuration))
    }
}

// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct ShowcasePreviewStyleKey: EnvironmentKey {
    static var defaultValue: AnyShowcasePreviewStyle = .init(.paged)
    static func reduce(value: inout AnyShowcasePreviewStyle, nextValue: () -> AnyShowcasePreviewStyle) {}
}

extension EnvironmentValues {
    /// The current Showcase style value.
    var showcasePreviewStyle: AnyShowcasePreviewStyle {
        get { self[ShowcasePreviewStyleKey.self] }
        set { self[ShowcasePreviewStyleKey.self] = newValue }
    }
}