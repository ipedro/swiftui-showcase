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
/// To configure the current Showcase layout style for a view hierarchy, use the
/// ``ShowcaseDocument/layoutStyle(_:)`` modifier.
public protocol ShowcaseLayoutStyle: DynamicProperty {
    /// A view that represents the body of a showcase layout.
    associatedtype Body: View

    /// The properties of a showcase layout.
    typealias Configuration = ShowcaseLayoutStyleConfiguration

    /// Creates a view that represents the body of a showcase layout.
    ///
    /// The system calls this method for each ``ShowcaseDocument`` instance in a view
    /// hierarchy where this style is the current Showcase layout style.
    /// 
    /// - Parameter configuration: The properties of a showcase layout.
    /// - Returns: A view that represents the body of a showcase layout.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

// MARK: - View Extension

extension View {
    /// Sets the style for Showcase within this view to a showcase layout layout style with a
    /// custom appearance and custom interaction behavior.
    /// 
    /// Use this modifier to set a specific style for Showcase instances
    /// within a view:
    /// 
    ///     Showcase(element)
    ///         .layoutStyle(.standard)
    /// 
    /// - Parameter style: Any showcase layout style.
    /// - Returns: A view that has the showcase layout style set in its environment.
    public func layoutStyle<S: ShowcaseLayoutStyle>(_ style: S) -> some View {
        environment(\.layoutStyle, style)
    }
}

// MARK: - Dynamic Property

private struct ResolvedShowcaseLayoutStyle<Style: ShowcaseLayoutStyle>: View {
    let configuration: ShowcaseLayoutStyleConfiguration
    let style: Style

    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

extension ShowcaseLayoutStyle {
    func resolve(configuration: Configuration) -> some View {
        ResolvedShowcaseLayoutStyle(configuration: configuration, style: self)
    }
}
