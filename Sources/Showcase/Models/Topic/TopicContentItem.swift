// TopicContentItem.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/08/25.
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

import Foundation

/// A type-erased wrapper for topic content items that preserves declaration order.
///
/// This enum allows heterogeneous content types to be stored in a single ordered
/// collection while maintaining type safety. Each case wraps a specific content type
/// and provides access to its unique identifier.
///
/// ## Example
///
/// ```swift
/// Topic {
///     Description { "Intro text" }
///     ExternalLink("Apple", url: URL(...)!)
///     CodeBlock { "print(\"Hello\")" }
///     Description { "More explanation" }
///     Example { Text("Demo") }
/// }
/// ```
///
/// The content items are stored as `[TopicContentItem]` in declaration order,
/// enabling views to render them exactly as specified in the builder DSL.
public enum TopicContentItem: Identifiable, Equatable {
    /// A text description or explanation.
    case description(Description)

    /// An external link to web content.
    case link(ExternalLink)

    /// A syntax-highlighted code block.
    case codeBlock(CodeBlock)

    /// A list (ordered or unordered).
    case list(ListItem)

    /// An embedded web view or external content.
    case embed(Embed)

    /// A live example of a SwiftUI view.
    case example(Example)

    /// A group of related examples displayed in a TabView.
    case exampleGroup(ExampleGroup)

    /// A special callout for notes, warnings, deprecations, etc.
    case note(Note)

    /// The unique identifier for this content item.
    ///
    /// Returns the underlying content type's identifier, ensuring stable
    /// identity for SwiftUI's diffing algorithm.
    public var id: AnyHashable {
        switch self {
        case let .description(description):
            AnyHashable(description.id)
        case let .link(link):
            AnyHashable(link.id)
        case let .codeBlock(codeBlock):
            AnyHashable(codeBlock.id)
        case let .list(list):
            AnyHashable(list.id)
        case let .embed(embed):
            AnyHashable(embed.id)
        case let .example(example):
            AnyHashable(example.id)
        case let .exampleGroup(group):
            AnyHashable(group.id)
        case let .note(note):
            AnyHashable(note)
        }
    }

    // MARK: - Equatable

    public static func == (lhs: TopicContentItem, rhs: TopicContentItem) -> Bool {
        lhs.id == rhs.id
    }
}
