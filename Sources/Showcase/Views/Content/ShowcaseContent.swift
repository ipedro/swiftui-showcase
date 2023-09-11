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

/// A view that displays the content of a showcase element, including title, description, previews, external links, and code blocks.
public struct ShowcaseContent: View {
    /// The configuration for the ShowcaseContent view.
    typealias Configuration = ShowcaseContentStyleConfiguration
    
    /// The style environment variable for displaying showcase content.
    @Environment(\.showcaseContentStyle) private var style
    
    /// The data representing the showcase content.
    let data: ShowcaseElement.Content
    
    /// The indentation level for the content.
    let level: Int
    
    /// The configuration for the showcase content view.
    var configuration: Configuration {
        .init(
            level: level,
            title: level > 0 ? Text(data.title) : nil,
            description: description,
            previews: ShowcasePreviews(data.previews),
            externalLinks: Configuration.ExternalLinks(data: data.links),
            codeBlocks: Configuration.CodeBlocks(data: data.codeBlocks)
        )
    }
    
    /// The description of the showcase content.
    var description: Text? {
        data.description.isEmpty ? nil : Text(data.description)
    }
    
    public var body: some View {
        style
            .makeBody(configuration: configuration)
            .id(data.id)
    }
}

// MARK: - Configuration

/// The configuration for styling the ShowcaseContent view.
public struct ShowcaseContentStyleConfiguration {
    public let level: Int
    public let title: Text?
    public let description: Text?
    public let previews: ShowcasePreviews?
    public let externalLinks: ExternalLinks?
    public let codeBlocks: CodeBlocks?
    
    /// A view that represents external links.
    public struct ExternalLinks: View {
        let data: [ShowcaseElement.ExternalLink]
        
        /// Initializes the view with external link data.
        /// - Parameter data: The external link data.
        init?(data: [ShowcaseElement.ExternalLink]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        /// The body view for displaying external links.
        public var body: some View {
            ForEach(data) {
                ShowcaseExternalLink(data: $0)
            }
        }
    }
    
    /// A view that represents code blocks.
    public struct CodeBlocks: View {
        let data: [ShowcaseElement.CodeBlock]
        
        /// Initializes the view with code block data.
        /// - Parameter data: The code block data.
        init?(data: [ShowcaseElement.CodeBlock]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        /// The body view for displaying code blocks.
        public var body: some View {
            ForEach(data) {
                ShowcaseCodeBlock($0)
            }
        }
    }
}

// MARK: - Standard Style

/// Extension for the standard style of ShowcaseContent.
extension ShowcaseContentStyle where Self == ShowcaseContentStyleStandard {
    static var standard: Self { .init() }
}

/// The standard style for showcasing content.
public struct ShowcaseContentStyleStandard: ShowcaseContentStyle {
    public func makeBody(configuration: Configuration) -> some View {
        LazyVStack(alignment: .leading, spacing: 30) {
            // Display the title with appropriate styling based on the indentation level.
            configuration.title.font(.system(title(configuration.level)))
            
            // If there are external links, display them horizontally.
            if let externalLinks = configuration.externalLinks {
                LazyHStack {
                    externalLinks
                }
            }
            
            // Display previews, description, and code blocks with appropriate styling.
            configuration.previews
            
            configuration.description.font(.system(description(configuration.level)))
            
            configuration.codeBlocks
                .padding(.top)
        }
    }
    
    /// Determines the title font style based on the indentation level.
    /// - Parameter level: The indentation level.
    /// - Returns: The font style for the title.
    func title(_ level: Int) -> SwiftUI.Font.TextStyle {
        switch level {
        case 0: return .largeTitle
        case 1: return .title
        default: return .title2
        }
    }
    
    /// Determines the description font style based on the indentation level.
    /// - Parameter level: The indentation level.
    /// - Returns: The font style for the description.
    func description(_ level: Int) -> SwiftUI.Font.TextStyle {
        switch level {
        case 0: return .subheadline
        case 1: return .body
        default: return .caption
        }
    }
}

// MARK: - Previews

struct ShowcaseContent_Previews: PreviewProvider {
    static let styles: [AnyShowcaseContentStyle] = [
        .init(.standard)
    ]
    
    static var previews: some View {
        ForEach(0...styles.count - 1, id: \.self) { index in
            ScrollView {
                ShowcaseContent(data: ShowcaseElement.accordion.content, level: index)
                    .showcaseContentStyle(styles[index])
                    .padding()
            }
        }
    }
}
