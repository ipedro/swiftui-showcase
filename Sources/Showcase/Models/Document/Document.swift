// Document.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11.09.23.
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

    /// Initializes a showcase document with the specified title, chapters and
    /// an optional description.
    /// - Parameters:
    ///   - title: The title of the document.
    ///   - icon: An optional default icon for topics.
    ///   - description: The optional description of the document.
    ///   - chapters: The chapters within the document.
    public init(
        _ title: String,
        icon: @escaping @autoclosure () -> Image,
        description: @escaping @autoclosure () -> String = "",
        _ chapters: [Chapter] = []
    ) {
        _title = Lazy(wrappedValue: title)
        _description = Lazy(wrappedValue: description())
        _icon = Lazy(wrappedValue: icon())
        self.chapters = chapters.sortedWithIcon(icon())
    }

    /// Initializes a showcase document with the specified title, chapters and
    /// an optional description.
    /// - Parameters:
    ///   - title: The title of the document.
    ///   - icon: An optional default icon for topics.
    ///   - description: The optional description of the document.
    ///   - chapters: The chapters within the document.
    public init(
        _ title: String,
        icon: @escaping @autoclosure () -> Image,
        description: @escaping @autoclosure () -> String = "",
        _ chapters: Chapter...
    ) {
        _title = Lazy(wrappedValue: title)
        _description = Lazy(wrappedValue: description())
        _icon = Lazy(wrappedValue: icon())
        self.chapters = chapters.sortedWithIcon(icon())
    }

    /// Initializes a showcase document with the specified title, chapters and
    /// an optional description.
    /// - Parameters:
    ///   - title: The title of the document.
    ///   - description: The optional description of the document.
    ///   - chapters: The chapters within the document.
    public init(
        _ title: String,
        description: @escaping @autoclosure () -> String = "",
        _ chapters: [Chapter] = []
    ) {
        _title = Lazy(wrappedValue: title)
        _description = Lazy(wrappedValue: description())
        _icon = Lazy(wrappedValue: nil)
        self.chapters = chapters.sorted()
    }

    /// Initializes a showcase document with the specified title, chapters and
    /// an optional description.
    /// - Parameters:
    ///   - title: The title of the document.
    ///   - description: The optional description of the document.
    ///   - chapters: The chapters within the document.
    public init(
        _ title: String,
        description: @escaping @autoclosure () -> String = "",
        _ chapters: Chapter...
    ) {
        _title = Lazy(wrappedValue: title)
        _description = Lazy(wrappedValue: description())
        _icon = Lazy(wrappedValue: nil)
        self.chapters = chapters.sorted()
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
