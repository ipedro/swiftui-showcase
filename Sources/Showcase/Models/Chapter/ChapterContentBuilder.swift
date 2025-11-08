// ChapterContentBuilder.swift
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

/// A type-erased component that can contribute to a chapter's content when
/// assembled through ``ChapterContentBuilder``.
public protocol ChapterContentConvertible {
    func merge(into content: inout Chapter.Content)
}

public extension Chapter {
    /// Aggregates the pieces declared inside a ``ChapterContentBuilder`` into a
    /// structure consumed by the chapter initializers.
    struct Content: AdditiveArithmetic {
        public var description: String?
        public var topics: [Topic]

        public init(description: String? = nil, topics: [Topic] = []) {
            self.description = description
            self.topics = topics
        }

        // MARK: - AdditiveArithmetic
        
        public static var zero: Chapter.Content {
            Chapter.Content()
        }
        
        public static func + (lhs: Chapter.Content, rhs: Chapter.Content) -> Chapter.Content {
            var result = lhs
            
            if let description = rhs.description {
                result.description = description
            }

            if !rhs.topics.isEmpty {
                result.topics.append(contentsOf: rhs.topics)
            }
            
            return result
        }
        
        public static func - (lhs: Chapter.Content, rhs: Chapter.Content) -> Chapter.Content {
            // Subtraction doesn't make semantic sense for content, so just return lhs
            lhs
        }
    }
}

/// A result builder that assembles ``Chapter.Content`` from typed DSL components.
@resultBuilder
public enum ChapterContentBuilder {
    public static func buildBlock(_ components: Chapter.Content...) -> Chapter.Content {
        components.reduce(.zero, +)
    }

    public static func buildOptional(_ component: Chapter.Content?) -> Chapter.Content {
        component ?? .zero
    }

    public static func buildEither(first component: Chapter.Content) -> Chapter.Content {
        component
    }

    public static func buildEither(second component: Chapter.Content) -> Chapter.Content {
        component
    }

    public static func buildArray(_ components: [Chapter.Content]) -> Chapter.Content {
        components.reduce(.zero, +)
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
