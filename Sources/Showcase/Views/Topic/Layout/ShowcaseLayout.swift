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

public struct ShowcaseLayout: View {
    @Environment(\.layoutStyle) private var style

    let configuration: ShowcaseLayoutStyleConfiguration

    public init(_ configuration: ShowcaseLayoutStyleConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        AnyShowcaseLayoutStyle(style).makeBody(configuration: configuration)
    }
}

// MARK: - Configuration

/// The configuration for a showcase view.
public struct ShowcaseLayoutStyleConfiguration {
    /// The children views within the showcase.
    public let children: ShowcaseChildren?
    /// The index view for navigating within the showcase.
    public let indexList: ShowcaseIndexList?
    /// The content view of the showcase.
    public let content: Content
    
    public struct Content: View {
        var configuration: ShowcaseContent.Configuration
        
        public var body: some View {
            ShowcaseContent(configuration).equatable()
        }
    }
}
