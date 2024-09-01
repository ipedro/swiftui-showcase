// Copyright (c) 2024 Pedro Almeida
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

extension Topic {
    /// A result builder for creating code blocks.
    @resultBuilder public struct PreviewBuilder {
        /// Builds an array of code blocks from individual components.
        public static func buildBlock() -> [Preview] { [] }
        
        /// Builds an array of code blocks from variadic components.
        public static func buildBlock(_ components: Preview...) -> [Preview] { components }

        /// Builds an array of code blocks from variadic components.
        public static func buildBlock(_ components: AnyView...) -> [Preview] {
            components.map { Preview(preview: $0) }
        }

        public static func buildBlock(_ content: AnyView) -> [Preview] {
            [
                Preview(preview: content)
            ]
        }

        public static func buildBlock<Content>(_ content: Content) -> [Preview] where Content : View {
            [
                Preview { content }
            ]
        }

        public static func buildBlock<each Content>(_ content: repeat each Content) -> [Preview] where repeat each Content : View {
            var previews = [AnyView]()
            _ = (repeat (each content, previews.append(AnyView(each content))))
            return previews.map { Preview(preview: $0) }
        }
    }
}
