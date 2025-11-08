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

import SwiftUI

/// Describes a piece of textual content that can be attached to topics or chapters.
public struct Description {
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
        public var description: String?
        
        /// Ordered heterogeneous content items that preserve declaration order.
        ///
        /// This array stores all content items (links, code blocks, previews, embeds)
        /// in the exact order they were declared in the builder DSL, enabling
        /// flexible content composition and rendering.
        public var items: [TopicContentItem]
        
        // Backward compatibility: separate arrays computed from items
        public var links: [ExternalLink]
        public var embeds: [Embed]
        public var codeBlocks: [CodeBlock]
        public var examples: [Example]
        public var children: [Topic]

        public init(
            description: String? = nil,
            items: [TopicContentItem] = [],
            links: [ExternalLink] = [],
            embeds: [Embed] = [],
            codeBlocks: [CodeBlock] = [],
            examples: [Example] = [],
            children: [Topic] = []
        ) {
            self.description = description
            self.items = items
            self.links = links
            self.embeds = embeds
            self.codeBlocks = codeBlocks
            self.examples = examples
            self.children = children
        }

        // MARK: - AdditiveArithmetic
        
        public static var zero: Topic.Content {
            Topic.Content()
        }
        
        public static func + (lhs: Topic.Content, rhs: Topic.Content) -> Topic.Content {
            var result = lhs
            
            if let description = rhs.description {
                result.description = description
            }
            
            if !rhs.items.isEmpty {
                result.items.append(contentsOf: rhs.items)
            }

            if !rhs.links.isEmpty {
                result.links.append(contentsOf: rhs.links)
            }

            if !rhs.embeds.isEmpty {
                result.embeds.append(contentsOf: rhs.embeds)
            }

            if !rhs.codeBlocks.isEmpty {
                result.codeBlocks.append(contentsOf: rhs.codeBlocks)
            }

            if !rhs.examples.isEmpty {
                result.examples.append(contentsOf: rhs.examples)
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
        result.examples.append(example)
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
        content.description = value
    }
}

extension Example: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.example(self))
        content.examples.append(self)
    }
}

extension CodeBlock: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.codeBlock(self))
        content.codeBlocks.append(self)
    }
}

extension ExternalLink: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.link(self))
        content.links.append(self)
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
        content.embeds.append(self)
    }
}

extension Topic: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.children.append(self)
    }
}
