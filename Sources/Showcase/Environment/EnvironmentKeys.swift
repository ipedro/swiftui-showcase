// EnvironmentKeys.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 20.04.24.
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

struct ScrollViewKey: EnvironmentKey {
    static var defaultValue: ScrollViewProxy?
}

struct NodeDepthKey: EnvironmentKey {
    static var defaultValue: Int = .zero
}

struct CodeBlockThemeKey: EnvironmentKey {
    static var defaultValue: ShowcaseCodeBlockTheme?
}

struct CodeBlockWordWrapKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

struct ContentTitleFontKey: EnvironmentKey {
    static var defaultValue: Font?
}

struct ContentBodyFontKey: EnvironmentKey {
    static var defaultValue: Font?
}

struct ScrollViewSelectionKey: EnvironmentKey {
    static var defaultValue: Binding<Topic.ID?>?
}
