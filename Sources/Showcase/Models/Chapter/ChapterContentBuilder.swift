// ChapterContentBuilder.swift
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

import Foundation

/// A type-erased component that can contribute to a chapter's content when
/// assembled through ``ChapterContentBuilder``.
public protocol ChapterContentConvertible {
    func merge(into content: inout Chapter.Content)
}

public extension Chapter {
    /// Aggregates the pieces declared inside a ``ChapterContentBuilder`` into a
    /// structure consumed by the chapter initializers.
    struct Content {
        public var description: String?
        public var topics: [Topic]

        public init(description: String? = nil, topics: [Topic] = []) {
            self.description = description
            self.topics = topics
        }

        mutating func merge(_ other: Self) {
            if let description = other.description {
                self.description = description
            }

            if !other.topics.isEmpty {
                topics.append(contentsOf: other.topics)
            }
        }
    }
}

/// A result builder that assembles ``Chapter.Content`` from typed DSL components.
@resultBuilder
public enum ChapterContentBuilder {
    public static func buildBlock(_ components: Chapter.Content...) -> Chapter.Content {
        components.reduce(into: Chapter.Content()) { partialResult, component in
            partialResult.merge(component)
        }
    }

    public static func buildOptional(_ component: Chapter.Content?) -> Chapter.Content {
        component ?? .init()
    }

    public static func buildEither(first component: Chapter.Content) -> Chapter.Content {
        component
    }

    public static func buildEither(second component: Chapter.Content) -> Chapter.Content {
        component
    }

    public static func buildArray(_ components: [Chapter.Content]) -> Chapter.Content {
        components.reduce(into: Chapter.Content()) { partialResult, component in
            partialResult.merge(component)
        }
    }

    public static func buildExpression(_ expression: Chapter.Content) -> Chapter.Content {
        expression
    }

    public static func buildExpression(_ expression: ChapterContentConvertible) -> Chapter.Content {
        var content = Chapter.Content()
        expression.merge(into: &content)
        return content
    }

    public static func buildExpression(_ expression: [ChapterContentConvertible]) -> Chapter.Content {
        expression.reduce(into: Chapter.Content()) { partialResult, element in
            element.merge(into: &partialResult)
        }
    }

    public static func buildLimitedAvailability(_ component: Chapter.Content) -> Chapter.Content {
        component
    }
}

extension Chapter.Content: ChapterContentConvertible {
    public func merge(into content: inout Chapter.Content) {
        content.merge(self)
    }
}

extension Description: ChapterContentConvertible {
    public func merge(into content: inout Chapter.Content) {
        content.description = value
    }
}

extension Topic: ChapterContentConvertible {
    public func merge(into content: inout Chapter.Content) {
        content.topics.append(self)
    }
}

extension Array: ChapterContentConvertible where Element == Topic {
    public func merge(into content: inout Chapter.Content) {
        content.topics.append(contentsOf: self)
    }
}
