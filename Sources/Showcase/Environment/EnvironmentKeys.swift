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

/// An internal key needed to save style data in the environment
struct LinkStyleKey: EnvironmentKey {
    static var defaultValue: AnyButtonStyle = .init(.standard)
}

/// An internal key needed to save style data in the environment
struct StyleKey: EnvironmentKey {
    static var defaultValue: any ShowcaseLayoutStyle = .automatic
}

/// An internal key needed to save style data in the environment
struct IndexMenuStyleKey: EnvironmentKey {
    static var defaultValue: any ShowcaseIndexMenuStyle = .menu()
}

/// An internal key needed to save style data in the environment
struct IndexListStyleKey: EnvironmentKey {
    static var defaultValue: any ShowcaseIndexListStyle = .bulletList
}

/// An internal key needed to save style data in the environment
struct PreviewStyleKey: EnvironmentKey {
    static var defaultValue: any ShowcasePreviewStyle = .plain
}

/// An internal key needed to save style data in the environment
struct CodeBlockStyleKey: EnvironmentKey {
    static var defaultValue: any ShowcaseCodeBlockStyle = .automatic
}

/// An internal key needed to save style data in the environment
struct ContentStyleKey: EnvironmentKey {
    static var defaultValue: any ShowcaseContentStyle = .automatic
}

struct ScrollViewKey: EnvironmentKey {
    static var defaultValue: ScrollViewProxy?
}

struct NodeDepthKey: EnvironmentKey {
    static var defaultValue: Int = .zero
}
