// TopicContentBuilder.swift
// Copyright (c) 2025 Pedro Almeida
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
        self.value = builder()
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
    struct Content {
        public var description: String?
        public var links: [Link]
        public var embeds: [Embed]
        public var codeBlocks: [CodeBlock]
        public var previews: [Preview]
        public var children: [Topic]

        public init(
            description: String? = nil,
            links: [Link] = [],
            embeds: [Embed] = [],
            codeBlocks: [CodeBlock] = [],
            previews: [Preview] = [],
            children: [Topic] = []
        ) {
            self.description = description
            self.links = links
            self.embeds = embeds
            self.codeBlocks = codeBlocks
            self.previews = previews
            self.children = children
        }

        mutating func merge(_ other: Self) {
            if let description = other.description {
                self.description = description
            }

            if !other.links.isEmpty {
                links.append(contentsOf: other.links)
            }

            if !other.embeds.isEmpty {
                embeds.append(contentsOf: other.embeds)
            }

            if !other.codeBlocks.isEmpty {
                codeBlocks.append(contentsOf: other.codeBlocks)
            }

            if !other.previews.isEmpty {
                previews.append(contentsOf: other.previews)
            }

            if !other.children.isEmpty {
                children.append(contentsOf: other.children)
            }
        }
    }
}

/// A result builder that assembles ``Topic.Content`` from typed DSL components.
@resultBuilder
public enum TopicContentBuilder {
    public static func buildBlock(_ components: Topic.Content...) -> Topic.Content {
        components.reduce(into: Topic.Content()) { partialResult, component in
            partialResult.merge(component)
        }
    }

    public static func buildOptional(_ component: Topic.Content?) -> Topic.Content {
        component ?? Topic.Content()
    }

    public static func buildEither(first component: Topic.Content) -> Topic.Content {
        component
    }

    public static func buildEither(second component: Topic.Content) -> Topic.Content {
        component
    }

    public static func buildArray(_ components: [Topic.Content]) -> Topic.Content {
        components.reduce(into: Topic.Content()) { partialResult, component in
            partialResult.merge(component)
        }
    }

    public static func buildExpression(_ expression: Topic.Content) -> Topic.Content {
        expression
    }

    public static func buildExpression(_ expression: TopicContentConvertible) -> Topic.Content {
        var content = Topic.Content()
        expression.merge(into: &content)
        return content
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

extension Topic.Content: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.merge(self)
    }
}

extension Description: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.description = value
    }
}

extension Topic.Preview: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.previews.append(self)
    }
}

extension Topic.CodeBlock: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.codeBlocks.append(self)
    }
}

extension Topic.Link: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.links.append(self)
    }
}

extension Topic.Embed: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.embeds.append(self)
    }
}

extension Topic: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.children.append(self)
    }
}

// Note: Swift doesn't allow multiple conditional Array conformances to the same protocol.
// Individual element types (Topic, Preview, CodeBlock, Link, Embed) conform directly,
// and the result builder handles arrays automatically.

/// Collects links produced by a ``Topic.LinkBuilder`` into the topic content DSL.
public struct TopicLinks: TopicContentConvertible {
    private let builder: () -> [Topic.Link]

    public init(@Topic.LinkBuilder _ builder: @escaping () -> [Topic.Link]) {
        self.builder = builder
    }

    public func merge(into content: inout Topic.Content) {
        let links = builder()
        guard !links.isEmpty else { return }
        content.links.append(contentsOf: links)
    }
}

/// Collects embeds produced by an ``Topic/EmbedBuilder`` into the topic content DSL.
public struct TopicEmbeds: TopicContentConvertible {
    private let builder: () -> [Topic.Embed]

    public init(@Topic.EmbedBuilder _ builder: @escaping () -> [Topic.Embed]) {
        self.builder = builder
    }

    public func merge(into content: inout Topic.Content) {
        let embeds = builder()
        guard !embeds.isEmpty else { return }
        content.embeds.append(contentsOf: embeds)
    }
}

/// Collects code blocks produced by a ``Topic.CodeBlockBuilder`` into the topic content DSL.
public struct TopicCodeBlocks: TopicContentConvertible {
    private let builder: () -> [Topic.CodeBlock]

    public init(@Topic.CodeBlockBuilder _ builder: @escaping () -> [Topic.CodeBlock]) {
        self.builder = builder
    }

    public func merge(into content: inout Topic.Content) {
        let codeBlocks = builder()
        guard !codeBlocks.isEmpty else { return }
        content.codeBlocks.append(contentsOf: codeBlocks)
    }
}

/// Collects previews produced by a ``Topic/PreviewBuilder`` into the topic content DSL.
public struct TopicPreviews: TopicContentConvertible {
    private let builder: () -> [Topic.Preview]

    public init(@Topic.PreviewBuilder _ builder: @escaping () -> [Topic.Preview]) {
        self.builder = builder
    }

    public func merge(into content: inout Topic.Content) {
        let previews = builder()
        guard !previews.isEmpty else { return }
        content.previews.append(contentsOf: previews)
    }
}

/// Collects child topics produced by a ``TopicBuilder`` into the topic content DSL.
public struct TopicChildren: TopicContentConvertible {
    private let builder: () -> [Topic]

    public init(@TopicBuilder _ builder: @escaping () -> [Topic]) {
        self.builder = builder
    }

    public func merge(into content: inout Topic.Content) {
        let children = builder()
        guard !children.isEmpty else { return }
        content.children.append(contentsOf: children)
    }
}

/// Convenience helper mirroring ``TopicPreviews`` while avoiding explicit type names in the DSL.
@inlinable
public func Previews(@Topic.PreviewBuilder _ builder: @escaping () -> [Topic.Preview]) -> TopicPreviews {
    TopicPreviews(builder)
}

/// Convenience helper mirroring ``TopicCodeBlocks`` while avoiding explicit type names in the DSL.
@inlinable
public func Code(@Topic.CodeBlockBuilder _ builder: @escaping () -> [Topic.CodeBlock]) -> TopicCodeBlocks {
    TopicCodeBlocks(builder)
}

/// Convenience helper mirroring ``TopicLinks`` while avoiding explicit type names in the DSL.
@inlinable
public func Links(@Topic.LinkBuilder _ builder: @escaping () -> [Topic.Link]) -> TopicLinks {
    TopicLinks(builder)
}

/// Convenience helper mirroring ``TopicEmbeds`` while avoiding explicit type names in the DSL.
@inlinable
public func Embeds(@Topic.EmbedBuilder _ builder: @escaping () -> [Topic.Embed]) -> TopicEmbeds {
    TopicEmbeds(builder)
}

/// Convenience helper mirroring ``TopicChildren`` while avoiding explicit type names in the DSL.
@inlinable
public func Children(@TopicBuilder _ builder: @escaping () -> [Topic]) -> TopicChildren {
    TopicChildren(builder)
}

/// Convenience helper matching the DSL style for constructing previews inline.
@inlinable
public func Preview(
    _ title: String? = nil,
    codeBlock: Topic.CodeBlock? = nil,
    @ViewBuilder preview: @escaping () -> some View
) -> Topic.Preview {
    Topic.Preview(title, codeBlock: codeBlock, preview: preview)
}
