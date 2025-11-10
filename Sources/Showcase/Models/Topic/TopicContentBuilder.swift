// TopicContentBuilder.swift
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

import Foundation
import SwiftUI

/// Describes a piece of textual content that can be attached to topics or chapters.
public struct Description: View, Identifiable {
    public let id = UUID()
    public let value: String

    @inlinable
    public init(_ value: String) {
        self.value = value
    }

    /// Creates descriptive text using a closure, which is handy for
    /// multi-line string literals built with trailing-closure syntax.
    @inlinable
    public init(_ builder: () -> String) {
        value = builder()
    }
    
    /// Description acts as a marker in ViewBuilder contexts.
    /// Returns an empty view - the actual description is extracted by the showcase system.
    public var body: some View {
        EmptyView()
    }
}

/// A type-erased component that can contribute to a topic's content when
/// assembled through ``TopicContentBuilder``.
public protocol TopicContentConvertible {
    func merge(into content: inout Topic.Content)
}

public extension Topic {
    /// Aggregates the pieces declared inside a ``TopicContentBuilder`` into a
    /// single structure consumed by the topic initializers.
    struct Content: AdditiveArithmetic {
        /// Ordered heterogeneous content items that preserve declaration order.
        ///
        /// This array stores all content items (links, code blocks, examples, embeds)
        /// in the exact order they were declared in the builder DSL, enabling
        /// flexible content composition and rendering.
        public var items: [TopicContentItem]
        
        /// Child topics for hierarchical navigation.
        public var children: [Topic]

        public init(
            items: [TopicContentItem] = [],
            children: [Topic] = []
        ) {
            self.items = items
            self.children = children
        }

        // MARK: - AdditiveArithmetic
        
        public static var zero: Topic.Content {
            Topic.Content()
        }
        
        public static func + (lhs: Topic.Content, rhs: Topic.Content) -> Topic.Content {
            var result = lhs
            
            if !rhs.items.isEmpty {
                result.items.append(contentsOf: rhs.items)
            }

            if !rhs.children.isEmpty {
                result.children.append(contentsOf: rhs.children)
            }
            
            return result
        }
        
        public static func - (lhs: Topic.Content, rhs: Topic.Content) -> Topic.Content {
            // Subtraction doesn't make semantic sense for content, so just return lhs
            lhs
        }
    }
}

/// A result builder that assembles ``Topic.Content`` from typed DSL components.
@resultBuilder
public enum TopicContentBuilder {
    public static func buildBlock(_ components: Topic.Content...) -> Topic.Content {
        components.reduce(.zero, +)
    }

    public static func buildOptional(_ component: Topic.Content?) -> Topic.Content {
        component ?? .zero
    }

    public static func buildEither(first component: Topic.Content) -> Topic.Content {
        component
    }

    public static func buildEither(second component: Topic.Content) -> Topic.Content {
        component
    }

    public static func buildArray(_ components: [Topic.Content]) -> Topic.Content {
        components.reduce(.zero, +)
    }

    public static func buildExpression(_ expression: Topic.Content) -> Topic.Content {
        expression
    }

    public static func buildExpression(_ expression: TopicContentConvertible) -> Topic.Content {
        var content = Topic.Content()
        expression.merge(into: &content)
        return content
    }

    public static func buildExpression<V: View>(@ViewBuilder content: @escaping () -> V) -> Topic.Content {
        var result = Topic.Content()
        let example = Example(example: content)
        result.items.append(.example(example))
        return result
    }

    public static func buildExpression(_ expression: [TopicContentConvertible]) -> Topic.Content {
        expression.reduce(into: Topic.Content()) { partialResult, element in
            element.merge(into: &partialResult)
        }
    }

    public static func buildLimitedAvailability(_ component: Topic.Content) -> Topic.Content {
        component
    }
}

extension Description: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        // Extract code blocks from markdown and split into alternating Description/CodeBlock items
        let parts = extractCodeBlocks(from: value)
        for part in parts {
            content.items.append(part)
        }
    }
    
    /// Extracts markdown code blocks and returns alternating Description and CodeBlock items.
    private func extractCodeBlocks(from text: String) -> [TopicContentItem] {
        let pattern = "```[a-z]*\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            // If regex fails, return original description
            return [.description(self)]
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
        
        guard !matches.isEmpty else {
            // No code blocks found - return original description
            return [.description(self)]
        }
        
        var items: [TopicContentItem] = []
        var currentIndex = 0
        
        for match in matches {
            let matchRange = match.range
            
            // Add text before this code block as Description
            if currentIndex < matchRange.location {
                let textRange = NSRange(location: currentIndex, length: matchRange.location - currentIndex)
                let textContent = nsString.substring(with: textRange)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !textContent.isEmpty {
                    items.append(.description(Description(textContent)))
                }
            }
            
            // Extract code block content (group 1 - content between ```)
            if match.numberOfRanges > 1 {
                let codeRange = match.range(at: 1)
                let code = nsString.substring(with: codeRange)
                let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !trimmed.isEmpty {
                    items.append(.codeBlock(CodeBlock(text: { trimmed })))
                }
            }
            
            currentIndex = matchRange.location + matchRange.length
        }
        
        // Add remaining text after last code block
        if currentIndex < nsString.length {
            let textRange = NSRange(location: currentIndex, length: nsString.length - currentIndex)
            let textContent = nsString.substring(with: textRange)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !textContent.isEmpty {
                items.append(.description(Description(textContent)))
            }
        }
        
        return items.isEmpty ? [.description(self)] : items
    }
}

extension Example: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.example(self))
    }
}

extension CodeBlock: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.codeBlock(self))
    }
}

extension ExternalLink: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.link(self))
    }
}

extension Optional: TopicContentConvertible where Wrapped: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        guard case let .some(wrapped) = self else {
            return
        }
        wrapped.merge(into: &content)
    }
}

extension Embed: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.embed(self))
    }
}

extension Topic: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.children.append(self)
    }
}
