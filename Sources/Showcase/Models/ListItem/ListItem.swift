// ListItem.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/13/25.
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

/// Represents a list (ordered or unordered) extracted from markdown.
public struct ListItem: Identifiable, Hashable, Equatable {
    /// The unique identifier for the list.
    public let id = UUID()

    /// The type of list.
    public enum ListType: Equatable, Hashable {
        case ordered
        case unordered
    }

    /// The type of this list (ordered or unordered).
    public let type: ListType

    /// The items in this list.
    public let items: [String]

    public static func == (lhs: ListItem, rhs: ListItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Initializes a list item.
    /// - Parameters:
    ///   - type: The type of list (ordered or unordered).
    ///   - items: The items in the list.
    public init(type: ListType, items: [String]) {
        self.type = type
        self.items = items
    }
}
