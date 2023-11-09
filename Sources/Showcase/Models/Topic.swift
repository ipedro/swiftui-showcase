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

/// Represents a showcase element used for displaying rich documentation.
///
/// The documentation can include code examples, descriptions, previews, links, and subtopics.
public struct Topic: Identifiable {
    /// The unique identifier for the topic.
    public let id = UUID()
    
    /// Code blocks associated with the topic.
    public var codeBlocks: [CodeBlock]
    
    /// Description of the topic.
    public var description: String
    
    /// External links associated with the topic.
    public var links: [Link]
    
    /// External content associated with the topic.
    public var embeds: [Embed]
    
    /// Previews configuration for the topic.
    public var previews: AnyView?

    /// Optional title of the preview.
    public var previewTitle: String?

    public var icon: AnyView?

    /// Title of the topic.
    public var title: String
    
    /// Optional child topics.
    public var children: [Topic]?
    
    var allChildren: [Topic] {
        guard let children = children else { return [] }
        return children.flatMap { [$0] + $0.allChildren }
    }
    
    var isEmpty: Bool {
        codeBlocks.isEmpty &&
        description.isEmpty &&
        links.isEmpty &&
        children?.isEmpty != false
    }

    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - children: Optional child showcase topics (default is nil).
    ///   - code: <#code description#>
    ///   - codeBlocks: A closure returning code examples (default is an empty array).
    ///   - description: A closure returning the description of the showcase element (default is an empty string).
    ///   - embeds: <#embeds description#>
    ///   - links: A closure returning external links associated with the showcase element (default is an empty array).
    ///   - title: The title of the showcase element.
    public init(
        _ title: String,
        description: () -> String = { "" },
        @LinkBuilder links: () -> [Link] = { [] },
        @EmbedBuilder embeds: () -> [Embed] = { [] },
        @CodeBlockBuilder code: () -> [CodeBlock] = { [] },
        children: [Topic]? = nil
    ) {
        self.icon = nil
        self.children = children
        self.codeBlocks = code()
        self.description = description()
        self.links = links()
        self.embeds = embeds()
        self.previews = nil
        self.previewTitle = nil
        self.title = title
    }

    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - children: Optional child showcase topics (default is nil).
    ///   - code: <#code description#>
    ///   - codeBlocks: A closure returning code examples (default is an empty array).
    ///   - description: A closure returning the description of the showcase element (default is an empty string).
    ///   - embeds: <#embeds description#>
    ///   - links: A closure returning external links associated with the showcase element (default is an empty array).
    ///   - previewTitle: Optional previews title
    ///   - previews: Optional previews.
    ///   - title: The title of the showcase element.
    public init<P: View>(
        _ title: String,
        description: () -> String = { "" },
        @LinkBuilder links: () -> [Link] = { [] },
        @EmbedBuilder embeds: () -> [Embed] = { [] },
        @CodeBlockBuilder code: () -> [CodeBlock] = { [] },
        children: [Topic]? = nil,
        previewTitle: String? = "Preview",
        @ViewBuilder previews: () -> P
    ) {
        self.icon = nil
        self.children = children
        self.codeBlocks = code()
        self.description = description()
        self.links = links()
        self.embeds = embeds()
        self.previews = .init(previews())
        self.previewTitle = previewTitle
        self.title = title
    }

    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - children: Optional child showcase topics (default is nil).
    ///   - code: <#code description#>
    ///   - codeBlocks: A closure returning code examples (default is an empty array).
    ///   - description: A closure returning the description of the showcase element (default is an empty string).
    ///   - embeds: <#embeds description#>
    ///   - icon: <#icon description#>
    ///   - links: A closure returning external links associated with the showcase element (default is an empty array).
    ///   - previewTitle: <#previewTitle description#>
    ///   - previews: Optional previews.
    ///   - title: The title of the showcase element.
    public init<I: View, P: View>(
        _ title: String,
        description: () -> String = { "" },
        @ViewBuilder icon: () -> I,
        @LinkBuilder links: () -> [Link] = { [] },
        @EmbedBuilder embeds: () -> [Embed] = { [] },
        @CodeBlockBuilder code: () -> [CodeBlock] = { [] },
        children: [Topic]? = nil,
        previewTitle: String? = "Preview",
        @ViewBuilder previews: () -> P
    ) {
        self.icon = .init(icon())
        self.children = children
        self.codeBlocks = code()
        self.description = description()
        self.links = links()
        self.embeds = embeds()
        self.previews = .init(previews())
        self.previewTitle = previewTitle
        self.title = title
    }
}

extension Topic: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.title.localizedStandardCompare(rhs.title) != .orderedDescending
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
