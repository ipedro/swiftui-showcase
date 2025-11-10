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

    /// Ordered content items that preserve declaration order.
    ///
    /// This array contains all content items (links, code blocks, examples, embeds)
    /// in the exact order they were declared in the builder DSL.
    @Lazy public var items: [TopicContentItem]

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
        _icon = Lazy(wrappedValue: icon)
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
        _icon = Lazy(wrappedValue: nil)
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
        items.isEmpty
            && (children?.isEmpty ?? true)
    }

    /// The first text description from the items array, or empty string if none exists.
    var firstDescription: String {
        for item in items {
            if case let .description(description) = item {
                return description.value
            }
        }
        return ""
    }
}

extension Topic: View {
    public var body: some View {
        ShowcaseNavigationTopic(self)
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
            || items.contains(where: { item in
                switch item {
                case let .description(description):
                    return description.value.localizedCaseInsensitiveContains(query)
                case let .example(example):
                    return example.title?.localizedCaseInsensitiveContains(query) == true
                case let .exampleGroup(group):
                    return group.title?.localizedCaseInsensitiveContains(query) == true
                        || group.examples.contains(where: { $0.title?.localizedCaseInsensitiveContains(query) == true })
                case let .codeBlock(codeBlock):
                    return codeBlock.rawValue.localizedCaseInsensitiveContains(query)
                        || codeBlock.title?.localizedCaseInsensitiveContains(query) == true
                case let .link(link):
                    return link.url.absoluteString.localizedCaseInsensitiveContains(query)
                        || link.name.description.localizedCaseInsensitiveContains(query)
                case let .list(list):
                    return list.items.contains(where: { $0.localizedCaseInsensitiveContains(query) })
                case let .note(note):
                    return note.content.localizedCaseInsensitiveContains(query)
                        || note.type.title.localizedCaseInsensitiveContains(query)
                case .embed:
                    return false
                }
            })

        var copy = self
        copy.children = children?.compactMap { $0.search(query: query) }
        return (isMatch || copy.children?.isEmpty == false) ? copy : nil
    }
}
