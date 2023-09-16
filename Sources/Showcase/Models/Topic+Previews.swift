//  Copyright (c) 2023 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import SwiftUI

extension Topic {
    /// Represents the previews configuration for a showcase element's content.
    public struct Previews {
        /// Minimum width of the preview.
        public var minWidth: CGFloat?
        
        /// Ideal width of the preview.
        public var idealWidth: CGFloat?
        
        /// Maximum width of the preview.
        public var maxWidth: CGFloat?
        
        /// Minimum height of the preview.
        public var minHeight: CGFloat?
        
        /// Ideal height of the preview.
        public var idealHeight: CGFloat?
        
        /// Maximum height of the preview.
        public var maxHeight: CGFloat?
        
        /// Alignment of the preview content.
        public var alignment: Alignment
        
        /// Title of the preview.
        public var title: String?
        
        /// The content to be displayed in the preview.
        public var content: AnyView
        
        /// Initializes the previews configuration with the specified parameters.
        /// - Parameters:
        ///   - minWidth: Minimum width of the preview (default is nil).
        ///   - idealWidth: Ideal width of the preview (default is nil).
        ///   - maxWidth: Maximum width of the preview (default is nil).
        ///   - minHeight: Minimum height of the preview (default is nil).
        ///   - idealHeight: Ideal height of the preview (default is 250).
        ///   - maxHeight: Maximum height of the preview (default is nil).
        ///   - alignment: Alignment of the content within the preview (default is .center).
        ///   - title: The title of the preview (default is nil).
        ///   - content: A closure returning the content of the preview.
        public init<V: View>(
            minWidth: CGFloat? = nil,
            idealWidth: CGFloat? = nil,
            maxWidth: CGFloat? = nil,
            minHeight: CGFloat? = nil,
            idealHeight: CGFloat? = 200,
            maxHeight: CGFloat? = nil,
            alignment: Alignment = .center,
            title: String? = nil,
            @ViewBuilder content: () -> V
        ) {
            self.minWidth = minWidth
            self.idealWidth = idealWidth
            self.maxWidth = maxWidth
            self.minHeight = minHeight
            self.idealHeight = idealHeight
            self.maxHeight = maxHeight
            self.alignment = alignment
            self.title = title
            self.content = .init(content())
        }
    }
}
