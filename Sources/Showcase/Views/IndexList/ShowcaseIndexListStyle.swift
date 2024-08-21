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
/// all index lists within a view hierarchy.
///
/// To configure the current Showcase style for a view hierarchy, use the
/// ``ShowcaseDocument/showcaseIndexListStyle(_:)`` modifier.
public protocol ShowcaseIndexListStyle: DynamicProperty {
    /// A view that represents the body of an index list view.
    associatedtype Body: View

    /// The properties of an index list view.
    typealias Configuration = ShowcaseIndexListConfiguration

    /// Creates a view that represents the body of an index list view.
    ///
    /// The system calls this method for each ``ShowcaseDocument`` instance in a view
    /// hierarchy where this style is the current index list style.
    ///
    /// - Parameter configuration: The properties of an index list view.
    /// - Returns: A view that represents the body of an index list view.
    @ViewBuilder func makeBody(configuration: Configuration) -> Body
}

// MARK: - View Extension

extension View {
    /// Sets the style for ``ShowcaseDocument`` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    /// 
    /// Use this modifier to set a specific style for ``ShowcaseDocument`` instances
    /// within a view:
    /// 
    ///     ShowcaseNavigationStack()
    ///         .showcaseIndexListStyle(MyCustomStyle())
    /// 
    /// - Parameter style: Any index list style.
    /// - Returns: A view that has the index list style set in its environment.
    public func showcaseIndexListStyle<S: ShowcaseIndexListStyle>(_ style: S) -> some View {
        environment(\.indexListStyle, style)
    }
}

// MARK: - Dynamic Property

private struct ResolvedShowcaseIndexListStyle<Style: ShowcaseIndexListStyle>: View {
    let configuration: ShowcaseIndexListConfiguration
    let style: Style

    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

extension ShowcaseIndexListStyle {
    func resolve(configuration: Configuration) -> some View {
        ResolvedShowcaseIndexListStyle(configuration: configuration, style: self)
    }
}
