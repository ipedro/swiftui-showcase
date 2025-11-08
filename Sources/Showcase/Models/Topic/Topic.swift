// Topic.swift
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

/// Represents a showcase element used for displaying rich documentation.
///
/// The documentation can include code examples, descriptions, previews, links, and subtopics.
public struct Topic: Identifiable {
    /// The unique identifier for the topic.
    public let id = UUID()
    
    /// Ordered content items that preserve declaration order.
    ///
    /// This array contains all content items (links, code blocks, previews, embeds)
    /// in the exact order they were declared in the builder DSL.
    @Lazy public var items: [TopicContentItem]

    /// Code blocks associated with the topic.
    @Lazy public var codeBlocks: [CodeBlock]

    /// Description of the topic.
    @Lazy public var description: String

    /// External links associated with the topic.
    @Lazy public var links: [Link]

    /// External contents associated with the topic.
    @Lazy public var embeds: [Embed]

    /// Previews configuration for the topic.
    @Lazy public var previews: [Preview]

    /// Optional icon for the topic.
    @Lazy public var icon: Image?

    /// Title of the topic.
    @Lazy public var title: String

    /// Optional child topics.
    public var children: [Topic]?

    var allChildren: [Topic] {
        guard let children = children else { return [] }
        var result: [Topic] = []
        result.reserveCapacity(children.count * 2) // Optimize allocation
        for child in children {
            result.append(child)
            result.append(contentsOf: child.allChildren)
        }
        return result
    }

    /// Initializes a showcase element using a ``TopicContentBuilder`` closure
    /// to describe all of its data while preserving the existing API surface.
    /// - Parameters:
    ///   - title: The title of the topic.
    ///   - icon: A closure returning an optional icon of the preview when shown in a list.
    ///   - content: A builder closure that produces the content associated with the topic.
    public init(
        _ title: String,
        icon: @escaping @autoclosure () -> Image,
        @TopicContentBuilder _ content: () -> Content = { Content() }
    ) {
        let icon = icon()
        let content = content()

        _items = Lazy(wrappedValue: content.items)
        _codeBlocks = Lazy(wrappedValue: content.codeBlocks)
        _description = Lazy(wrappedValue: content.description ?? "")
        _embeds = Lazy(wrappedValue: content.embeds)
        _icon = Lazy(wrappedValue: icon)
        _links = Lazy(wrappedValue: content.links)
        _previews = Lazy(wrappedValue: content.previews)
        _title = Lazy(wrappedValue: title)
        children = content.children.isEmpty ? nil : content.children
    }

    /// Initializes a showcase element using a ``TopicContentBuilder`` closure
    /// to describe all of its data without providing an explicit icon.
    /// - Parameters:
    ///   - title: The title of the topic.
    ///   - content: A builder closure that produces the content associated with the topic.
    public init(
        _ title: String,
        @TopicContentBuilder _ content: () -> Content = { Content() }
    ) {
        let content = content()

        _items = Lazy(wrappedValue: content.items)
        _codeBlocks = Lazy(wrappedValue: content.codeBlocks)
        _description = Lazy(wrappedValue: content.description ?? "")
        _embeds = Lazy(wrappedValue: content.embeds)
        _icon = Lazy(wrappedValue: nil)
        _links = Lazy(wrappedValue: content.links)
        _previews = Lazy(wrappedValue: content.previews)
        _title = Lazy(wrappedValue: title)
        children = content.children.isEmpty ? nil : content.children
    }

    func withIcon(_ proposal: Image?) -> Topic {
        // Early exit if no icon proposal or already has icon
        guard let proposal = proposal, icon == nil else { return self }

        var copy = self
        copy._icon = Lazy(wrappedValue: proposal)

        // Only process children if they exist
        if let children = copy.children, !children.isEmpty {
            copy.children = children.map { $0.withIcon(proposal) }
        }

        return copy
    }

    var isEmpty: Bool {
        // Use short-circuit evaluation for early exit
        description.isEmpty
            && codeBlocks.isEmpty
            && links.isEmpty
            && embeds.isEmpty
            && previews.isEmpty
            && (children?.isEmpty ?? true)
    }

    // MARK: - Icon

    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - title: The title of the topic.
    ///   - icon: A closure returning an optional icon of the preview when shown in a list.
    ///   - description: A closure returning the description of the topic (default is an empty string).
    ///   - links: A closure returning external links associated with the topic (default is an empty array).
    ///   - embeds: A closure returning external contents associated with the topic (default is an empty string).
    ///   - code: A closure returning code examples (default is an empty array).
    ///   - children: Optional child showcase topics (default is nil).
    ///   - previews: Optional previews.
    @available(*, deprecated, message: "Use init(_:icon:_:) with TopicContentBuilder instead.")
    public init(
        _ title: String,
        icon: @escaping @autoclosure () -> Image,
        description: @escaping @autoclosure () -> String = "",
        @Link.Builder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @PreviewBuilder previews: @escaping () -> [Preview] = Array.init,
        children: [Topic]? = nil
    ) {
        let linksArray = links()
        let embedsArray = embeds()
        let codeBlocksArray = codeBlocks()
        let previewsArray = previews()
        
        // Build items array preserving original order (links, embeds, code, previews)
        var itemsArray: [TopicContentItem] = []
        itemsArray.reserveCapacity(linksArray.count + embedsArray.count + codeBlocksArray.count + previewsArray.count)
        itemsArray.append(contentsOf: linksArray.map { .link($0) })
        itemsArray.append(contentsOf: embedsArray.map { .embed($0) })
        itemsArray.append(contentsOf: codeBlocksArray.map { .codeBlock($0) })
        itemsArray.append(contentsOf: previewsArray.map { .preview($0) })
        
        _items = Lazy(wrappedValue: itemsArray)
        _items = Lazy(wrappedValue: itemsArray)
_items = Lazy(wrappedValue: [])
        _codeBlocks = Lazy(wrappedValue: codeBlocksArray)
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embedsArray)
        _icon = Lazy(wrappedValue: icon())
        _links = Lazy(wrappedValue: linksArray)
        _previews = Lazy(wrappedValue: previewsArray)
        _title = Lazy(wrappedValue: title)
        self.children = children
    }

    /// Initializes a showcase element with the specified parameters using a
    /// ``TopicBuilder`` closure for composing child topics.
    /// - Parameters mirror ``Topic/init(_:icon:description:links:embeds:code:previews:children:)``.
    @available(*, deprecated, message: "Use init(_:icon:_:) with TopicContentBuilder instead.")
    public init(
        _ title: String,
        icon: @escaping @autoclosure () -> Image,
        description: @escaping @autoclosure () -> String = "",
        @Link.Builder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @PreviewBuilder previews: @escaping () -> [Preview] = Array.init,
        @TopicBuilder _ children: () -> [Topic]
    ) {
        let children = children()
        let linksArray = links()
        let embedsArray = embeds()
        let codeBlocksArray = codeBlocks()
        let previewsArray = previews()
        
        var itemsArray: [TopicContentItem] = []
        itemsArray.reserveCapacity(linksArray.count + embedsArray.count + codeBlocksArray.count + previewsArray.count)
        itemsArray.append(contentsOf: linksArray.map { .link($0) })
        itemsArray.append(contentsOf: embedsArray.map { .embed($0) })
        itemsArray.append(contentsOf: codeBlocksArray.map { .codeBlock($0) })
        itemsArray.append(contentsOf: previewsArray.map { .preview($0) })
        
        _items = Lazy(wrappedValue: itemsArray)
_items = Lazy(wrappedValue: [])
        _codeBlocks = Lazy(wrappedValue: codeBlocksArray)
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embedsArray)
        _icon = Lazy(wrappedValue: icon())
        _links = Lazy(wrappedValue: linksArray)
        _previews = Lazy(wrappedValue: previewsArray)
        _title = Lazy(wrappedValue: title)
        self.children = children.isEmpty ? nil : children
    }

    // MARK: - Icon & View Builder

    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - title: The title of the topic.
    ///   - icon: A closure returning an optional icon of the preview when shown in a list.
    ///   - description: A closure returning the description of the topic (default is an empty string).
    ///   - links: A closure returning external links associated with the topic (default is an empty array).
    ///   - embeds: A closure returning external contents associated with the topic (default is an empty string).
    ///   - code: A closure returning code examples (default is an empty array).
    ///   - children: Optional child showcase topics (default is nil).
    ///   - previews: Optional previews.
    @available(*, deprecated, message: "Use init(_:icon:_:) with TopicContentBuilder instead.")
    public init(
        _ title: String,
        icon: @escaping @autoclosure () -> Image,
        description: @escaping @autoclosure () -> String = "",
        @Link.Builder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @ViewBuilder previews: @escaping () -> some View,
        children: [Topic]? = nil
    ) {
_items = Lazy(wrappedValue: [])
        _codeBlocks = Lazy(wrappedValue: codeBlocks())
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embeds())
        _icon = Lazy(wrappedValue: icon())
        _links = Lazy(wrappedValue: links())
        _previews = Lazy(wrappedValue: [Preview(preview: previews())])
        _title = Lazy(wrappedValue: title)
        self.children = children
    }

    /// Initializes a showcase element with the specified parameters using a
    /// ``TopicBuilder`` closure for composing child topics.
    /// - Parameters mirror ``Topic/init(_:icon:description:links:embeds:code:previews:children:)``.
    @available(*, deprecated, message: "Use init(_:icon:_:) with TopicContentBuilder instead.")
    public init(
        _ title: String,
        icon: @escaping @autoclosure () -> Image,
        description: @escaping @autoclosure () -> String = "",
        @Link.Builder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @ViewBuilder previews: @escaping () -> some View,
        @TopicBuilder _ children: () -> [Topic]
    ) {
        let children = children()
_items = Lazy(wrappedValue: [])
        _codeBlocks = Lazy(wrappedValue: codeBlocks())
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embeds())
        _icon = Lazy(wrappedValue: icon())
        _links = Lazy(wrappedValue: links())
        _previews = Lazy(wrappedValue: [Preview(preview: previews())])
        _title = Lazy(wrappedValue: title)
        self.children = children.isEmpty ? nil : children
    }

    // MARK: - No Icon

    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - title: The title of the topic.
    ///   - description: A closure returning the description of the topic (default is an empty string).
    ///   - links: A closure returning external links associated with the topic (default is an empty array).
    ///   - embeds: A closure returning external contents associated with the topic (default is an empty string).
    ///   - code: A closure returning code examples (default is an empty array).
    ///   - children: Optional child showcase topics (default is nil).
    ///   - previews: Optional previews.
    @available(*, deprecated, message: "Use init(_:_: ) that accepts a TopicContentBuilder closure instead.")
    public init(
        _ title: String,
        description: @escaping @autoclosure () -> String = "",
        @Link.Builder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @PreviewBuilder previews: @escaping () -> [Preview] = Array.init,
        children: [Topic]? = nil
    ) {
_items = Lazy(wrappedValue: [])
        _codeBlocks = Lazy(wrappedValue: codeBlocks())
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embeds())
        _icon = Lazy(wrappedValue: nil)
        _links = Lazy(wrappedValue: links())
        _previews = Lazy(wrappedValue: previews())
        _title = Lazy(wrappedValue: title)
        self.children = children
    }

    /// Initializes a showcase element with the specified parameters using a
    /// ``TopicBuilder`` closure for composing child topics.
    /// - Parameters mirror ``Topic/init(_:description:links:embeds:code:previews:children:)``.
    @available(*, deprecated, message: "Use init(_:_: ) that accepts a TopicContentBuilder closure instead.")
    public init(
        _ title: String,
        description: @escaping @autoclosure () -> String = "",
        @Link.Builder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @PreviewBuilder previews: @escaping () -> [Preview] = Array.init,
        @TopicBuilder _ children: () -> [Topic]
    ) {
        let children = children()
_items = Lazy(wrappedValue: [])
        _codeBlocks = Lazy(wrappedValue: codeBlocks())
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embeds())
        _icon = Lazy(wrappedValue: nil)
        _links = Lazy(wrappedValue: links())
        _previews = Lazy(wrappedValue: previews())
        _title = Lazy(wrappedValue: title)
        self.children = children.isEmpty ? nil : children
    }

    // MARK: - View Builder

    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - title: The title of the topic.
    ///   - description: A closure returning the description of the topic (default is an empty string).
    ///   - links: A closure returning external links associated with the topic (default is an empty array).
    ///   - embeds: A closure returning external contents associated with the topic (default is an empty string).
    ///   - code: A closure returning code examples (default is an empty array).
    ///   - children: Optional child showcase topics (default is nil).
    ///   - previews: Optional previews.
    @available(*, deprecated, message: "Use init(_:_: ) that accepts a TopicContentBuilder closure instead.")
    public init(
        _ title: String,
        description: @escaping @autoclosure () -> String = "",
        @Link.Builder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @ViewBuilder previews: @escaping () -> some View,
        children: [Topic]? = nil
    ) {
_items = Lazy(wrappedValue: [])
        _codeBlocks = Lazy(wrappedValue: codeBlocks())
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embeds())
        _icon = Lazy(wrappedValue: nil)
        _links = Lazy(wrappedValue: links())
        _previews = Lazy(wrappedValue: [Preview(preview: previews())])
        _title = Lazy(wrappedValue: title)
        self.children = children
    }

    /// Initializes a showcase element with the specified parameters using a
    /// ``TopicBuilder`` closure for composing child topics.
    /// - Parameters mirror ``Topic/init(_:description:links:embeds:code:previews:children:)``.
    @available(*, deprecated, message: "Use init(_:_: ) that accepts a TopicContentBuilder closure instead.")
    public init(
        _ title: String,
        description: @escaping @autoclosure () -> String = "",
        @Link.Builder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @ViewBuilder previews: @escaping () -> some View,
        @TopicBuilder _ children: () -> [Topic]
    ) {
        let children = children()
_items = Lazy(wrappedValue: [])
        _codeBlocks = Lazy(wrappedValue: codeBlocks())
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embeds())
        _icon = Lazy(wrappedValue: nil)
        _links = Lazy(wrappedValue: links())
        _previews = Lazy(wrappedValue: [Preview(preview: previews())])
        _title = Lazy(wrappedValue: title)
        self.children = children.isEmpty ? nil : children
    }
}

extension Topic: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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

extension Array: @retroactive Identifiable where Element == Topic {
    public var id: [Element.ID] {
        map(\.id)
    }
}

extension Topic {
    /// Searches for a query string within the topic, including descriptions, titles, code blocks, links, and recursively in child topics.
    /// - Parameter query: The text string to search for.
    /// - Returns: `true` if the query matches any part of the topic or its children, `false` otherwise.
    func search(query: String) -> Topic? {
        // Early exit: Use short-circuit evaluation to avoid unnecessary checks
        let isMatch = title.localizedCaseInsensitiveContains(query)
            || description.localizedCaseInsensitiveContains(query)
            || previews.contains(where: { $0.title?.localizedCaseInsensitiveContains(query) == true })
            || codeBlocks.contains(where: {
                $0.rawValue.localizedCaseInsensitiveContains(query)
                    || $0.title?.localizedCaseInsensitiveContains(query) == true
            })
            || links.contains(where: {
                $0.url.absoluteString.localizedCaseInsensitiveContains(query)
                    || $0.name.description.localizedCaseInsensitiveContains(query)
            })

        var copy = self
        copy.children = children?.compactMap { $0.search(query: query) }
        return (isMatch || copy.children?.isEmpty == false) ? copy : nil
    }
}
