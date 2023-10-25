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

struct ShowcaseContent: View, Equatable {
    typealias Configuration = ShowcaseContentStyleConfiguration
    @Environment(\.showcaseContentStyle) private var style
    let id: AnyHashable
    var configuration: Configuration
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
    
    static func == (lhs: ShowcaseContent, rhs: ShowcaseContent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Configuration

public struct ShowcaseContentStyleConfiguration {
    public let title: Text?
    public let description: Text?
    public let preview: ShowcasePreview?
    public let links: Links?
    public let embeds: Embeds?
    public let codeBoxes: CodeBoxes?
    
    /// A view that represents a list of web embeds.
    public struct Embeds: View {
        let data: [Topic.Embed]
        
        /// Initializes the view with external link data.
        /// - Parameter data: The external link data.
        init?(data: [Topic.Embed]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        public var body: some View {
            ForEach(data) {
                ShowcaseEmbed(data: $0)
            }
        }
    }
    
    /// A view that represents a list of external links.
    public struct Links: View {
        let data: [Topic.Link]
        
        /// Initializes the view with external link data.
        /// - Parameter data: The external link data.
        init?(data: [Topic.Link]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        /// The body view for displaying external links.
        public var body: some View {
            ForEach(data) {
                ShowcaseLink(data: $0)
            }
        }
    }
    
    /// A view that represents a list of code examples.
    public struct CodeBoxes: View {
        let data: [Topic.CodeBlock]
        
        /// Initializes the view with code block data.
        /// - Parameter data: The code block data.
        init?(data: [Topic.CodeBlock]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        /// The body view for displaying code blocks.
        public var body: some View {
            ForEach(data) {
                ShowcaseCodeBox($0)
            }
        }
    }
}
