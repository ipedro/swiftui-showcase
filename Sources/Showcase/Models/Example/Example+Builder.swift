// Example+Builder.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/8/25.
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

public extension Example {
    /// A result builder for creating examples.
    @resultBuilder struct Builder {
        /// Builds an array of examples from no components.
        public static func buildBlock() -> [Example] { [] }

        /// Builds an array of examples from variadic components.
        public static func buildBlock(_ components: Example...) -> [Example] { components }

        /// Builds an array of examples from variadic AnyView components.
        public static func buildBlock(_ components: AnyView...) -> [Example] {
            components.map { Example(example: $0) }
        }

        /// Builds an array of examples from a single AnyView.
        public static func buildBlock(_ content: AnyView) -> [Example] {
            [Example(example: content)]
        }

        /// Builds an array of examples from a single view.
        public static func buildBlock<Content>(_ content: Content) -> [Example] where Content: View {
            [Example { content }]
        }

        /// Builds an array of examples from variadic view components.
        public static func buildBlock<each Content>(_ content: repeat each Content) -> [Example] where repeat each Content: View {
            var examples = [AnyView]()
            _ = (repeat (each content, examples.append(AnyView(each content))))
            return examples.map { Example(example: $0) }
        }
    }
}
