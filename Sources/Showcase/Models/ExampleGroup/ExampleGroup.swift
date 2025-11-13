// ExampleGroup.swift
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

/// A group of related examples displayed together in a TabView.
public struct ExampleGroup: Identifiable, Hashable, Equatable {
    /// The unique identifier for the example group.
    public let id = UUID()

    /// The title of the example group.
    public var title: String?

    /// The examples in this group.
    public var examples: [Example]

    public static func == (lhs: ExampleGroup, rhs: ExampleGroup) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Initializes an example group with a title and examples.
    /// - Parameters:
    ///   - title: Optional title for the group.
    ///   - examples: Array of examples to group together.
    public init(_ title: String? = nil, examples: [Example]) {
        self.title = title
        self.examples = examples
    }

    /// Initializes an example group with a title and example builder.
    /// - Parameters:
    ///   - title: Optional title for the group.
    ///   - builder: A result builder that produces examples.
    public init(_ title: String? = nil, @ExampleGroupBuilder builder: () -> [Example]) {
        self.title = title
        examples = builder()
    }
}

// MARK: - Result Builder

@resultBuilder
public enum ExampleGroupBuilder {
    public static func buildBlock(_ components: Example...) -> [Example] {
        components
    }

    public static func buildArray(_ components: [[Example]]) -> [Example] {
        components.flatMap(\.self)
    }

    public static func buildOptional(_ component: [Example]?) -> [Example] {
        component ?? []
    }

    public static func buildEither(first component: [Example]) -> [Example] {
        component
    }

    public static func buildEither(second component: [Example]) -> [Example] {
        component
    }
}
