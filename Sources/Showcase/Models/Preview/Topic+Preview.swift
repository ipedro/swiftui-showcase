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
    /// A view associated with a showcase element.
    public struct Preview: Identifiable {
        /// The unique identifier for the preview.
        public let id = UUID()

        /// Previews configuration for the topic.
        public var content: () -> AnyView

        /// Optional title for the preview.
        public var title: String?

        public var codeBlock: CodeBlock?

        /// Initializes a preview with a title and raw text.
        /// - Parameters:
        ///   - title: Optional title for the preview.
        ///   - preview: A content view representing the preview.
        public init<V>(
            _ title: String? = nil,
            codeBlock: CodeBlock? = nil,
            @ViewBuilder preview: @escaping () -> V
        ) where V: View {
            self.title = title
            self.codeBlock = codeBlock
            self.content = { AnyView(preview()) }
        }

        /// Initializes a preview with a title and raw text.
        /// - Parameters:
        ///   - title: Optional title for the preview.
        ///   - preview: A content view representing the preview.
        init(
            _ title: String? = nil,
            codeBlock: CodeBlock? = nil,
            preview: @escaping @autoclosure () -> AnyView
        ) {
            self.title = title
            self.codeBlock = codeBlock
            self.content = preview
        }
    }
}
