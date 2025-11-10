// Example.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/10/25.
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

/// A live example view associated with a showcase element.
public struct Example: Identifiable, Hashable, Equatable {
    /// The unique identifier for the example.
    public let id = UUID()

    /// Example view configuration for the topic.
    public var content: () -> any View

    /// Optional title for the example.
    public var title: String?

    /// Optional description for the example.
    public var description: String?

    /// Optional code block to display alongside the example.
    public var codeBlock: CodeBlock?

    public static func == (lhs: Example, rhs: Example) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    /// Initializes an example with a title and view builder.
    /// - Parameters:
    ///   - title: Optional title for the example.
    ///   - description: Optional description for the example.
    ///   - codeBlock: Optional code block to show the implementation.
    ///   - example: A content view representing the example.
    public init(
        _ title: String? = nil,
        description: String? = nil,
        codeBlock: CodeBlock? = nil,
        @ViewBuilder example: @escaping () -> some View
    ) {
        self.title = title
        self.description = description
        self.codeBlock = codeBlock
        content = { example() }
    }

    /// Initializes an example with a title and autoclosure view.
    /// - Parameters:
    ///   - title: Optional title for the example.
    ///   - description: Optional description for the example.
    ///   - codeBlock: Optional code block to show the implementation.
    ///   - example: A content view representing the example.
    init(
        _ title: String? = nil,
        description: String? = nil,
        codeBlock: CodeBlock? = nil,
        example: @escaping @autoclosure () -> any View
    ) {
        self.title = title
        self.description = description
        self.codeBlock = codeBlock
        content = example
    }
}
