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

extension EnvironmentValues {
    /// The current topic nesting level of the environment.
    var scrollView: ScrollViewProxy? {
        get { self[ScrollViewKey.self] }
        set { self[ScrollViewKey.self] = newValue }
    }

    /// The current topic nesting level of the environment.
    var nodeDepth: Int {
        get { self[NodeDepthKey.self] }
        set { self[NodeDepthKey.self] = newValue }
    }

    /// The current Showcase style value.
    var previewStyle: any ShowcasePreviewStyle {
        get { self[PreviewStyleKey.self] }
        set { self[PreviewStyleKey.self] = newValue }
    }

    /// The current Showcase style value.
    var codeBlockStyle: any ShowcaseCodeBlockStyle {
        get { self[CodeBlockStyleKey.self] }
        set { self[CodeBlockStyleKey.self] = newValue }
    }

    /// The current Showcase style value.
    var contentStyle: any ShowcaseContentStyle {
        get { self[ContentStyleKey.self] }
        set { self[ContentStyleKey.self] = newValue }
    }

    /// The current Showcase style value.
    var indexListStyle: any ShowcaseIndexListStyle {
        get { self[IndexListStyleKey.self] }
        set { self[IndexListStyleKey.self] = newValue }
    }

    /// The current index menu style value.
    var indexMenuStyle: any ShowcaseIndexMenuStyle {
        get { self[IndexMenuStyleKey.self] }
        set { self[IndexMenuStyleKey.self] = newValue }
    }

    /// The current Showcase layout style value.
    var layoutStyle: any ShowcaseLayoutStyle {
        get { self[StyleKey.self] }
        set { self[StyleKey.self] = newValue }
    }

    /// The current Showcase style value.
    var linkStyle: AnyButtonStyle {
        get { self[LinkStyleKey.self] }
        set { self[LinkStyleKey.self] = newValue }
    }

}
