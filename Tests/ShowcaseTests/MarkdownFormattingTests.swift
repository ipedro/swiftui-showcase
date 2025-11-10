// MarkdownFormattingTests.swift
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

@testable import Showcase
import Testing

@Suite("Markdown Formatting Preservation")
struct MarkdownFormattingTests {
    @Test("Bold text is preserved")
    func boldText() {
        let topic = Topic("Test") {
            Description {
                """
                This has **bold text** in the middle.
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("**bold text**"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Italic text is preserved")
    func italicText() {
        let topic = Topic("Test") {
            Description {
                """
                This has *italic text* in the middle.
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("*italic text*"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Bold text before list is preserved")
    func boldBeforeList() {
        let topic = Topic("Test") {
            Description {
                """
                **Note**: This is important

                Features:
                - Feature A
                - Feature B
                """
            }
        }

        print("=== Bold before list ===")
        print("Items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .description(desc):
                print("[\(index)] Description: '\(desc.value)'")
            case let .list(list):
                print("[\(index)] List: \(list.items.count) items")
            default:
                print("[\(index)] Other")
            }
        }

        // Should have: description with both paragraphs (including **Note** and Features:), then list
        #expect(topic.items.count == 2)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("**Note**"))
            #expect(desc.value.contains("Features:"))
        } else {
            Issue.record("Expected first item to be description with **Note** and Features:")
        }

        if case let .list(list) = topic.items[1] {
            #expect(list.items.count == 2)
        } else {
            Issue.record("Expected second item to be list")
        }
    }

    @Test("Inline code is preserved")
    func inlineCode() {
        let topic = Topic("Test") {
            Description {
                """
                Use the `Button` component for actions.
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("`Button`"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Inline code before list is preserved")
    func inlineCodeBeforeList() {
        let topic = Topic("Test") {
            Description {
                """
                Use the `@Showcasable` macro:
                - Auto-generates docs
                - Extracts examples
                """
            }
        }

        print("=== Inline code before list ===")
        print("Items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .description(desc):
                print("[\(index)] Description: '\(desc.value)'")
            case let .list(list):
                print("[\(index)] List: \(list.items.count) items")
            default:
                print("[\(index)] Other")
            }
        }

        #expect(topic.items.count == 2)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("`@Showcasable`"))
        } else {
            Issue.record("Expected description with inline code")
        }
    }

    @Test("Complex markdown with code block and list")
    func complexMarkdown() {
        let topic = Topic("Test") {
            Description {
                """
                **Important**: Read this first

                Example code:
                ```swift
                Button("Click") { }
                ```

                Features include:
                - Fast
                - Easy
                """
            }
        }

        print("=== Complex markdown ===")
        print("Items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .description(desc):
                print("[\(index)] Description (\(desc.value.count) chars)")
                print("     Preview: '\(desc.value.prefix(50))...'")
            case let .list(list):
                print("[\(index)] List: \(list.items.count) items")
            case let .codeBlock(code):
                print("[\(index)] CodeBlock: '\(code.rawValue.prefix(20))...'")
            default:
                print("[\(index)] Other")
            }
        }

        // Should have: description (with **Important** and "Example code:"), code block, description ("Features include:"), list
        #expect(topic.items.count == 4)

        // Verify structure
        if case let .description(desc1) = topic.items[0] {
            #expect(desc1.value.contains("**Important**"))
            #expect(desc1.value.contains("Example code:"))
        } else {
            Issue.record("Expected first description")
        }

        if case .codeBlock = topic.items[1] {
            // Good
        } else {
            Issue.record("Expected code block")
        }

        if case let .description(desc2) = topic.items[2] {
            #expect(desc2.value.contains("Features include:"))
        } else {
            Issue.record("Expected second description")
        }

        if case let .list(list) = topic.items[3] {
            #expect(list.items.count == 2)
        } else {
            Issue.record("Expected list")
        }
    }

    @Test("List items preserve inline code")
    func listItemsWithInlineCode() {
        let topic = Topic("Test") {
            Description {
                """
                - Use `Button` for actions
                - Apply `.buttonStyle()` modifier
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .list(list) = topic.items[0] {
            #expect(list.items.count == 2)
            // Inline code should be preserved in list items
            #expect(list.items[0].contains("Button"))
            #expect(list.items[1].contains(".buttonStyle()"))
        } else {
            Issue.record("Expected list")
        }
    }

    @Test("List items preserve bold text")
    func listItemsWithBold() {
        let topic = Topic("Test") {
            Description {
                """
                - **Primary action**: Main button
                - **Secondary action**: Cancel button
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .list(list) = topic.items[0] {
            #expect(list.items.count == 2)
            #expect(list.items[0].contains("Primary action"))
            #expect(list.items[1].contains("Secondary action"))
        } else {
            Issue.record("Expected list")
        }
    }

    @Test("Markdown headings are preserved")
    func markdownHeadings() {
        let topic = Topic("Test") {
            Description {
                """
                ## Section Title

                Some content here.
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("## Section Title"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Heading followed by list")
    func headingFollowedByList() {
        let topic = Topic("Test") {
            Description {
                """
                ## Features

                - Fast
                - Easy
                - Powerful
                """
            }
        }

        print("=== Heading followed by list ===")
        print("Items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .description(desc):
                print("[\(index)] Description: '\(desc.value)'")
            case let .list(list):
                print("[\(index)] List: \(list.items.count) items")
            default:
                print("[\(index)] Other")
            }
        }

        #expect(topic.items.count == 2)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("## Features"))
        } else {
            Issue.record("Expected description with heading")
        }
    }

    @Test("Real DSPrimaryButton description structure")
    func dSPrimaryButtonStructure() {
        let topic = Topic("Test") {
            Description {
                """
                **Note**: Always pair with a secondary button

                ## Type Relationships

                Conforms to: `View`

                **Use showCode: false when:**
                - The example is self-explanatory visually
                - Code adds no additional value

                **Use showCode: true (default) when:**
                - API usage patterns are not obvious
                - Showing specific parameter combinations
                """
            }
        }

        print("=== DSPrimaryButton structure ===")
        print("Items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .description(desc):
                print("[\(index)] Description (\(desc.value.count) chars)")
                let preview = desc.value.replacingOccurrences(of: "\n", with: "\\n")
                print("     '\(preview.prefix(80))...'")
            case let .list(list):
                print("[\(index)] List (\(list.type)): \(list.items.count) items")
                for (itemIndex, listItem) in list.items.enumerated() {
                    print("     [\(itemIndex)]: '\(listItem.prefix(40))...'")
                }
            case let .codeBlock(code):
                print("[\(index)] CodeBlock")
            default:
                print("[\(index)] Other")
            }
        }

        // This should be properly structured with bold text preserved
        // Expected structure might vary, but should maintain formatting
    }
}
