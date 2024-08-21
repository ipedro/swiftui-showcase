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
    var codeBlockTheme: ShowcaseCodeBlockTheme? {
        get { self[CodeBlockThemeKey.self] }
        set { self[CodeBlockThemeKey.self] = newValue }
    }
    
    /// The current Showcase style value.
    var linkStyle: AnyButtonStyle {
        get { self[LinkStyleKey.self] }
        set { self[LinkStyleKey.self] = newValue }
    }

    var codeBlockWordWrap: Bool {
        get { self[CodeBlockWordWrapKey.self] }
        set { self[CodeBlockWordWrapKey.self] = newValue }
    }
}
