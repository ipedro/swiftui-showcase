// Document.swift
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

import SwiftUI

/// Represents a document split into chapters, with navigatable chapters that
/// contain code examples, descriptions, and links.
public struct Document: Identifiable {
    /// The unique identifier for the document.
    public let id = UUID()

    /// The title of the document.
    @Lazy public var title: String

    /// An optional default icon for topics.
    @Lazy public var icon: Image?

    /// The optional description of the document.
    @Lazy public var description: String

    /// The chapters within the document.
    public var chapters: [Chapter]

    /// Initializes a showcase document using a ``DocumentContentBuilder`` closure
    /// that allows mixing descriptions and chapters in the builder DSL.
    /// - Parameters:
    ///   - title: The title of the document.
    ///   - content: A builder closure that produces the document's content.
    public init(
        _ title: String,
        @DocumentContentBuilder _ content: () -> Document.Content
    ) {
        let documentContent = content()
        _title = Lazy(wrappedValue: title)
        _description = Lazy(wrappedValue: documentContent.description ?? "")
        _icon = Lazy(wrappedValue: documentContent.icon)

        if let icon = documentContent.icon {
            chapters = documentContent.chapters.sortedWithIcon(icon)
        } else {
            chapters = documentContent.chapters.sorted()
        }
    }
}

private extension [Chapter] {
    func sortedWithIcon(_ icon: Image?) -> [Chapter] {
        sorted().map { $0.withIcon(icon) }
    }
}

extension Document: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Document: Comparable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.title.localizedStandardCompare(rhs.title) != .orderedDescending
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
