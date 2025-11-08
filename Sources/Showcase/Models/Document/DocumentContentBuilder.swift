// DocumentContentBuilder.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/9/25.
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

/// A type-erased component that can contribute to a document's content when
/// assembled through ``DocumentContentBuilder``.
public protocol DocumentContentConvertible {
    func merge(into content: inout Document.Content)
}

public extension Document {
    /// Aggregates the pieces declared inside a ``DocumentContentBuilder`` into a
    /// structure consumed by the document initializers.
    struct Content: AdditiveArithmetic {
        public var description: String?
        public var icon: Image?
        public var chapters: [Chapter]

        public init(description: String? = nil, icon: Image? = nil, chapters: [Chapter] = []) {
            self.description = description
            self.icon = icon
            self.chapters = chapters
        }

        // MARK: - AdditiveArithmetic
        
        public static var zero: Document.Content {
            Document.Content()
        }
        
        public static func + (lhs: Document.Content, rhs: Document.Content) -> Document.Content {
            var result = lhs
            
            if let description = rhs.description {
                result.description = description
            }
            
            if let icon = rhs.icon {
                result.icon = icon
            }
            
            if !rhs.chapters.isEmpty {
                result.chapters.append(contentsOf: rhs.chapters)
            }
            
            return result
        }
        
        public static func - (lhs: Document.Content, rhs: Document.Content) -> Document.Content {
            // Subtraction doesn't make semantic sense for content, so just return lhs
            lhs
        }
    }
}

// MARK: - Description Support

extension Description: DocumentContentConvertible {
    public func merge(into content: inout Document.Content) {
        content.description = value
    }
}

// MARK: - Icon Support

/// Sets the icon for a document.
public struct Icon: DocumentContentConvertible {
    let image: Image
    
    public init(_ image: Image) {
        self.image = image
    }
    
    public func merge(into content: inout Document.Content) {
        content.icon = image
    }
}

// MARK: - Content Support

extension Document.Content: DocumentContentConvertible {
    public func merge(into content: inout Document.Content) {
        content = self + content
    }
}

// MARK: - Chapter Support

extension Chapter: DocumentContentConvertible {
    public func merge(into content: inout Document.Content) {
        content.chapters.append(self)
    }
}

extension Array: DocumentContentConvertible where Element == Chapter {
    public func merge(into content: inout Document.Content) {
        content.chapters.append(contentsOf: self)
    }
}

// MARK: - Result Builder

@resultBuilder
public struct DocumentContentBuilder {
    public static func buildBlock(_ components: DocumentContentConvertible...) -> Document.Content {
        var content = Document.Content.zero
        for component in components {
            component.merge(into: &content)
        }
        return content
    }

    public static func buildOptional(_ component: Document.Content?) -> Document.Content {
        component ?? .zero
    }

    public static func buildEither(first component: Document.Content) -> Document.Content {
        component
    }

    public static func buildEither(second component: Document.Content) -> Document.Content {
        component
    }

    public static func buildArray(_ components: [Document.Content]) -> Document.Content {
        components.reduce(.zero, +)
    }

    public static func buildLimitedAvailability(_ component: Document.Content) -> Document.Content {
        component
    }

    public static func buildExpression(_ expression: DocumentContentConvertible) -> Document.Content {
        var content = Document.Content.zero
        expression.merge(into: &content)
        return content
    }

    public static func buildFinalResult(_ component: Document.Content) -> Document.Content {
        component
    }
}
