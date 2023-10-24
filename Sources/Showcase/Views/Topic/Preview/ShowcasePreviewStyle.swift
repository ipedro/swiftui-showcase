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
/// ``Showcase/showcasePreviewBoxStyle(_:)`` modifier.
public protocol ShowcasePreviewBoxStyle: GroupBoxStyle {}

// MARK: - View Extension

extension View {
    /// Sets the style for ``Showcase`` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for ``Showcase`` instances
    /// within a view:
    ///
    ///     Showcase()
    ///         .showcasePreviewBoxStyle(MyCustomStyle())
    ///
    public func showcasePreviewBoxStyle<S: ShowcasePreviewBoxStyle>(_ style: S) -> some View {
        environment(\.showcasePreviewBoxStyle, style)
    }
}

// MARK: - Environment Keys

/// A private key needed to save style data in the environment
private struct ShowcasePreviewBoxStyleKey: EnvironmentKey {
    static var defaultValue: any ShowcasePreviewBoxStyle = DefaultGroupBoxStyle()
}

extension EnvironmentValues {
    /// The current Showcase style value.
    var showcasePreviewBoxStyle: any ShowcasePreviewBoxStyle {
        get { self[ShowcasePreviewBoxStyleKey.self] }
        set { self[ShowcasePreviewBoxStyleKey.self] = newValue }
    }
}

extension DefaultGroupBoxStyle: ShowcasePreviewBoxStyle {}
