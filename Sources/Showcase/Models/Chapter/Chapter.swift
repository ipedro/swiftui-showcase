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

    public var children: [Topic]? { topics }

    /// Initializes a showcase chapter with the specified title and showcase topics.
    /// - Parameters:
    ///   - title: The title of the chapter.
    ///   - icon: Optional icon for the chapter.
    ///   - description: The optional description of the chapter.
    ///   - topics: The showcase topics within the chapter.
    public init(
        _ title: String,
        icon: (() -> Image)? = nil,
        description: @escaping () -> String = EmptyString,
        _ topics: [Topic] = []
    ) {
        _title = Lazy(wrappedValue: title)
        _description = Lazy(wrappedValue: description())
        _icon = Lazy(wrappedValue: icon?())
        self.topics = topics.sorted().map { $0.withIcon(icon?()) }
    }

    /// Initializes a showcase chapter with the specified title and showcase topics.
    /// - Parameters:
    ///   - title: The title of the chapter.
    ///   - icon: Optional icon for the chapter.
    ///   - description: The optional description of the chapter.
    ///   - topics: The showcase topics within the chapter.
    public init(
        _ title: String,
        icon: (() -> Image)? = nil,
        description: @escaping () -> String = EmptyString,
        _ topics: Topic...
    ) {
        self.init(
            title,
            icon: icon,
            description: description,
            topics
        )
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
        var copy = self
        let icon = copy.icon ?? proposal
        copy._icon = Lazy(wrappedValue: icon)
        copy.topics = copy.topics.map { $0.withIcon(icon) }
        return copy
    }

    /// Searches for a query string within the chapter, including the chapter title, description, and all contained topics.
    /// - Parameter query: The text string to search for.
    /// - Returns: `true` if the query matches any part of the chapter or its topics, `false` otherwise.
    func search(query: String) -> Chapter? {
        var isMatch = false

        // Convert query to lowercase for case-insensitive comparison.
        let query = query.lowercased()

        // Check the chapter title and description for a match.
        if title.localizedCaseInsensitiveContains(query) || description.localizedCaseInsensitiveContains(query) == true {
            isMatch = true
        }

        // Check all topics within the chapter.
        var copy = self
        copy.topics = topics.compactMap { $0.search(query: query) }
        return (isMatch || !copy.topics.isEmpty) ? copy : nil
    }
}
