// Example.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 08.11.25.
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
    public var content: () -> AnyView

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
    ///   - codeBlock: Optional code block to show the implementation.
    ///   - example: A content view representing the example.
    public init(
        _ title: String? = nil,
        codeBlock: CodeBlock? = nil,
        @ViewBuilder example: @escaping () -> some View
    ) {
        self.title = title
        description = nil
        self.codeBlock = codeBlock
        content = { AnyView(example()) }
    }

    /// Initializes an example with declarative content including previews and optional code blocks.
    /// - Parameters:
    ///   - title: Optional title for the example.
    ///   - content: Builder that returns the view and optional supporting content.
    public init(
        _ title: String? = nil,
        @ExampleContentBuilder content: () -> Content
    ) {
        let builtContent = content()
        self.title = title
        description = builtContent.descriptionText
        codeBlock = builtContent.codeBlock

        if let viewProvider = builtContent.view {
            self.content = viewProvider
        } else {
            assertionFailure("Example requires at least one View in its content builder.")
            self.content = { AnyView(EmptyView()) }
        }
    }

    /// Initializes an example with a title and autoclosure view.
    /// - Parameters:
    ///   - title: Optional title for the example.
    ///   - codeBlock: Optional code block to show the implementation.
    ///   - example: A content view representing the example.
    init(
        _ title: String? = nil,
        codeBlock: CodeBlock? = nil,
        example: @escaping @autoclosure () -> any View
    ) {
        self.title = title
        description = nil
        self.codeBlock = codeBlock
        content = { AnyView(example()) }
    }
}

// MARK: - Content Builder

public extension Example {
    /// Represents the components that can be assembled inside an `Example` builder.
    struct Content {
        var view: (() -> AnyView)?
        var codeBlock: CodeBlock?
        var descriptions: [String] = []

        init() {}

        init(view: @escaping () -> AnyView) {
            self.view = view
        }

        init(codeBlock: CodeBlock) {
            self.codeBlock = codeBlock
        }

        init(description: String) {
            descriptions = [description]
        }

        mutating func merge(_ other: Content) {
            if let view = other.view {
                if self.view != nil {
                    assertionFailure("Example builder received multiple view components; the last one will be used.")
                }
                self.view = view
            }

            if let codeBlock = other.codeBlock {
                if self.codeBlock != nil {
                    assertionFailure("Example builder received multiple code blocks; the last one will be used.")
                }
                self.codeBlock = codeBlock
            }

            if !other.descriptions.isEmpty {
                descriptions.append(contentsOf: other.descriptions)
            }
        }

        func merging(_ other: Content) -> Content {
            var combined = self
            combined.merge(other)
            return combined
        }

        /// Computed property that returns the concatenated description text.
        var descriptionText: String? {
            guard !descriptions.isEmpty else { return nil }
            return descriptions.joined(separator: "\n\n")
        }
    }
}

@resultBuilder
public enum ExampleContentBuilder {
    public static func buildBlock(_ components: Example.Content...) -> Example.Content {
        components.reduce(into: Example.Content()) { partialResult, component in
            partialResult.merge(component)
        }
    }

    public static func buildArray(_ components: [Example.Content]) -> Example.Content {
        components.reduce(into: Example.Content()) { partialResult, component in
            partialResult.merge(component)
        }
    }

    public static func buildOptional(_ component: Example.Content?) -> Example.Content {
        component ?? Example.Content()
    }

    public static func buildEither(first component: Example.Content) -> Example.Content {
        component
    }

    public static func buildEither(second component: Example.Content) -> Example.Content {
        component
    }

    public static func buildLimitedAvailability(_ component: Example.Content?) -> Example.Content {
        component ?? Example.Content()
    }

    public static func buildExpression<Content: View>(_ content: Content) -> Example.Content {
        Example.Content(view: { AnyView(content) })
    }

    public static func buildExpression(_ codeBlock: CodeBlock) -> Example.Content {
        Example.Content(codeBlock: codeBlock)
    }

    public static func buildExpression(_ description: Description) -> Example.Content {
        Example.Content(description: description.value)
    }

    public static func buildExpression(_ content: Example.Content) -> Example.Content {
        content
    }
}
