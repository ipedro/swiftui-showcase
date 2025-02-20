// Topic.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 16.09.23.
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
        return children.flatMap { [$0] + $0.allChildren }
    }

    func withIcon(_ proposal: Image?) -> Topic {
        var copy = self
        let icon = copy.icon ?? proposal
        copy._icon = Lazy(wrappedValue: icon)
        copy.children = copy.children?.map { $0.withIcon(icon) }
        return copy
    }

    var isEmpty: Bool {
        codeBlocks.isEmpty &&
            description.isEmpty &&
            links.isEmpty &&
            children?.isEmpty != false
    }

    // FIXME: Consolidar inits num só. criar equivalente "EmptyView" para os tipos? EmptyCodeblock, EmptyPreview, ..?

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
    public init(
        _ title: String,
        icon: (() -> Image)? = nil,
        description: @escaping @autoclosure () -> String = "",
        @LinkBuilder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        @PreviewBuilder previews: @escaping () -> [Preview] = Array.init,
        children: [Topic]? = nil
    ) {
        _codeBlocks = Lazy(wrappedValue: codeBlocks())
        _description = Lazy(wrappedValue: description())
        _embeds = Lazy(wrappedValue: embeds())
        _icon = Lazy(wrappedValue: icon?())
        _links = Lazy(wrappedValue: links())
        _previews = Lazy(wrappedValue: previews())
        _title = Lazy(wrappedValue: title)
        self.children = children
    }

    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - title: The title of the topic.
    ///   - icon: A closure returning an optional icon of the preview when shown in a list.
    ///   - description: A closure returning the description of the topic (default is an empty string).
    ///   - links: A closure returning external links associated with the topic (default is an empty array).
    ///   - embeds: A closure returning external contents associated with the topic (default is an empty string).
    ///   - code: A closure returning code examples (default is an empty array).
    ///   - children: Optional child showcase topics (default is nil).
    ///   - previewTitle: Optional previews title
    ///   - previews: Optional previews.
    public init<P: View>(
        _ title: String,
        icon: (() -> Image)? = nil,
        description: @escaping @autoclosure () -> String = "",
        @LinkBuilder links: @escaping () -> [Link] = Array.init,
        @EmbedBuilder embeds: @escaping () -> [Embed] = Array.init,
        @CodeBlockBuilder code codeBlocks: @escaping () -> [CodeBlock] = Array.init,
        previewTitle: String? = nil,
        @ViewBuilder previews: @escaping () -> P,
        children: [Topic]? = nil
    ) {
        self.init(
            title,
            icon: icon,
            description: description(),
            links: links,
            embeds: embeds,
            code: codeBlocks,
            previews: { Preview(previewTitle, preview: previews) },
            children: children
        )
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
        var isMatch = false
        // Convert query to lowercase for case-insensitive comparison.
        // Check the topic title, description, and optionally preview title for a match.
        if title.localizedCaseInsensitiveContains(query) || description.localizedCaseInsensitiveContains(query) {
            isMatch = true
        }

        // Check code blocks for a match in the raw value or title.
        if previews.contains(where: { $0.title?.localizedCaseInsensitiveContains(query) == true }) {
            isMatch = true
        }

        // Check code blocks for a match in the raw value or title.
        if codeBlocks.contains(where: { $0.rawValue.localizedCaseInsensitiveContains(query) || $0.title?.localizedCaseInsensitiveContains(query) == true }) {
            isMatch = true
        }

        // Check links for a match in the URL or the name of the link.
        if links.contains(where: { $0.url.absoluteString.localizedCaseInsensitiveContains(query) || $0.name.description.localizedCaseInsensitiveContains(query) }) {
            isMatch = true
        }

        var copy = self
        copy.children = children?.compactMap { $0.search(query: query) }
        return (isMatch || copy.children?.isEmpty == false) ? copy : nil
    }
}
