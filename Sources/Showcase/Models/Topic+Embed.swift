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

import Foundation
import WebKit

extension Topic {
    public struct Embed: Identifiable {
        public typealias NavigationHandler = (_ action: WKNavigationAction) -> WKNavigationActionPolicy
        public var id: String { url.absoluteString }
        public var url: URL
        public var navigationHandler: NavigationHandler
        public var isInteractionEnabled: Bool
        /// Minimum height of the preview.
        public var minHeight: CGFloat?

        public init?(
            _ url: URL?,
            minHeight: CGFloat? = nil,
            isInteractionEnabled: Bool = true,
            navigationHandler: @escaping NavigationHandler = { _ in .allow }
        ) {
            guard let url = url else { return nil }
            self.url = url
            self.minHeight = minHeight
            self.isInteractionEnabled = isInteractionEnabled
            self.navigationHandler = navigationHandler
        }
    }
}
