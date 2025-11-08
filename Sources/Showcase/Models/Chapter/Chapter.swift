// Chapter.swift
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

/// Represents a chapter within a showcase document, containing showcase topics.
public struct Chapter: Identifiable {
    /// The unique identifier for the chapter.
    public let id = UUID()

    /// The title of the chapter.
    @Lazy public var title: String

    /// Optional icon for the chapter.
    @Lazy public var icon: Image?

    /// The optional description of the chapter.
    @Lazy public var description: String

    /// The showcase topics within the chapter.
    public var topics: [Topic]

    /// Initializes a showcase chapter using a ``ChapterContentBuilder``
    /// closure to describe its description and topics while preserving the
    /// existing API surface.
    /// - Parameters:
    ///   - title: The title of the chapter.
    ///   - icon: Optional icon for the chapter.
    ///   - content: A builder closure that produces the chapter description and topics.
    public init(
        _ title: String,
        icon: @escaping @autoclosure () -> Image,
        @ChapterContentBuilder _ content: () -> Content = { Content() }
    ) {
        let icon = icon()
        let content = content()

        _title = Lazy(wrappedValue: title)
        _description = Lazy(wrappedValue: content.description ?? "")
        _icon = Lazy(wrappedValue: icon)
        topics = content.topics.sortedWithIcon(icon)
    }

    /// Initializes a showcase chapter using a ``ChapterContentBuilder`` closure
    /// to describe its description and topics without providing an explicit icon.
    /// - Parameters:
    ///   - title: The title of the chapter.
    ///   - content: A builder closure that produces the chapter description and topics.
    public init(
        _ title: String,
        @ChapterContentBuilder _ content: () -> Content = { Content() }
    ) {
        let content = content()

        _title = Lazy(wrappedValue: title)
        _description = Lazy(wrappedValue: content.description ?? "")
        _icon = Lazy(wrappedValue: nil)
        topics = content.topics.sorted()
    }
}

private extension [Topic] {
    func sortedWithIcon(_ icon: Image?) -> [Topic] {
        sorted().map { $0.withIcon(icon) }
    }
}

extension Chapter: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Chapter: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.title.localizedStandardCompare(rhs.title) != .orderedDescending
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Collection where Element == Chapter {
    func search(_ query: String) -> [Chapter] {
        compactMap {
            $0.search(query: query)
        }
    }
}

extension Chapter {
    func withIcon(_ proposal: Image?) -> Chapter {
        // Early exit if no icon proposal or already has icon
        guard let proposal = proposal, icon == nil else { return self }

        var copy = self
        copy._icon = Lazy(wrappedValue: proposal)

        // Only process topics if they exist
        if !copy.topics.isEmpty {
            copy.topics = copy.topics.map { $0.withIcon(proposal) }
        }

        return copy
    }

    /// Searches for a query string within the chapter, including the chapter
    /// title, description, and all contained topics.
    /// - Parameter query: The text string to search for.
    /// - Returns: `true` if the query matches any part of the chapter or its topics.
    func search(query: String) -> Chapter? {
        // Use short-circuit evaluation for early exit
        let isMatch = title.localizedCaseInsensitiveContains(query)
            || description.localizedCaseInsensitiveContains(query)

        // Check all topics within the chapter.
        var copy = self
        copy.topics = topics.compactMap { $0.search(query: query) }
        return (isMatch || !copy.topics.isEmpty) ? copy : nil
    }
}
