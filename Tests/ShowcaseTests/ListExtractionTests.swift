// ListExtractionTests.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/12/25.
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

@Suite("List Extraction from Markdown")
struct ListExtractionTests {
    @Test("Unordered list with dashes")
    func unorderedListDashes() {
        let topic = Topic("Test") {
            Description {
                """
                Intro text.

                - First item
                - Second item
                - Third item

                Outro text.
                """
            }
        }

        #expect(topic.items.count == 3)

        // Check first description
        if case let .description(desc) = topic.items[0] {
            #expect(desc.value == "Intro text.")
        } else {
            Issue.record("Expected description, got \(topic.items[0])")
        }

        // Check list
        if case let .list(list) = topic.items[1] {
            #expect(list.type == .unordered)
            #expect(list.items.count == 3)
            #expect(list.items[0] == "First item")
            #expect(list.items[1] == "Second item")
            #expect(list.items[2] == "Third item")
        } else {
            Issue.record("Expected list, got \(topic.items[1])")
        }

        // Check last description
        if case let .description(desc) = topic.items[2] {
            #expect(desc.value == "Outro text.")
        } else {
            Issue.record("Expected description, got \(topic.items[2])")
        }
    }

    @Test("Unordered list with asterisks")
    func unorderedListAsterisks() {
        let topic = Topic("Test") {
            Description {
                """
                * Item one
                * Item two
                * Item three
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .list(list) = topic.items[0] {
            #expect(list.type == .unordered)
            #expect(list.items.count == 3)
        } else {
            Issue.record("Expected list, got \(topic.items[0])")
        }
    }

    @Test("Unordered list with plus signs")
    func unorderedListPlus() {
        let topic = Topic("Test") {
            Description {
                """
                + Alpha
                + Beta
                + Gamma
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .list(list) = topic.items[0] {
            #expect(list.type == .unordered)
            #expect(list.items.count == 3)
        } else {
            Issue.record("Expected list, got \(topic.items[0])")
        }
    }

    @Test("Ordered list")
    func orderedList() {
        let topic = Topic("Test") {
            Description {
                """
                Steps to follow:

                1. First step
                2. Second step
                3. Third step
                4. Fourth step
                """
            }
        }

        #expect(topic.items.count == 2)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value == "Steps to follow:")
        } else {
            Issue.record("Expected description, got \(topic.items[0])")
        }

        if case let .list(list) = topic.items[1] {
            #expect(list.type == .ordered)
            #expect(list.items.count == 4)
            #expect(list.items[0] == "First step")
            #expect(list.items[3] == "Fourth step")
        } else {
            Issue.record("Expected list, got \(topic.items[1])")
        }
    }

    @Test("Mixed ordered and unordered lists")
    func mixedLists() {
        let topic = Topic("Test") {
            Description {
                """
                Unordered features:

                - Feature A
                - Feature B

                Ordered steps:

                1. Step one
                2. Step two
                """
            }
        }

        #expect(topic.items.count == 4)

        // First description
        if case let .description(desc) = topic.items[0] {
            #expect(desc.value == "Unordered features:")
        } else {
            Issue.record("Expected description")
        }

        // First list (unordered)
        if case let .list(list) = topic.items[1] {
            #expect(list.type == .unordered)
            #expect(list.items.count == 2)
        } else {
            Issue.record("Expected unordered list")
        }

        // Second description
        if case let .description(desc) = topic.items[2] {
            #expect(desc.value == "Ordered steps:")
        } else {
            Issue.record("Expected description")
        }

        // Second list (ordered)
        if case let .list(list) = topic.items[3] {
            #expect(list.type == .ordered)
            #expect(list.items.count == 2)
        } else {
            Issue.record("Expected ordered list")
        }
    }

    @Test("List with code block")
    func listWithCodeBlock() {
        let topic = Topic("Test") {
            Description {
                """
                Features:

                - Built-in styles
                - Custom styles
                - Accessibility support

                Example code:

                ```swift
                Button("Click me") {
                    print("Clicked")
                }
                ```

                More details here.
                """
            }
        }

        // Should have: description, list, description, code block, description
        #expect(topic.items.count == 5)

        if case .description = topic.items[0] {
            // OK
        } else {
            Issue.record("Expected description at index 0")
        }

        if case let .list(list) = topic.items[1] {
            #expect(list.items.count == 3)
        } else {
            Issue.record("Expected list at index 1")
        }

        if case .description = topic.items[2] {
            // OK
        } else {
            Issue.record("Expected description at index 2")
        }

        if case .codeBlock = topic.items[3] {
            // OK
        } else {
            Issue.record("Expected code block at index 3")
        }

        if case .description = topic.items[4] {
            // OK
        } else {
            Issue.record("Expected description at index 4")
        }
    }

    @Test("Nested list items with indentation")
    func nestedListItems() {
        // Note: Nested lists might not be fully supported, but should at least parse top level
        let topic = Topic("Test") {
            Description {
                """
                - Parent item
                  - Nested item
                - Another parent
                """
            }
        }

        // Should extract at least the parent items
        #expect(topic.items.count >= 1)

        if case let .list(list) = topic.items[0] {
            #expect(list.type == .unordered)
            // May capture nested items differently depending on markdown parser
            #expect(list.items.count >= 2)
        } else {
            Issue.record("Expected list")
        }
    }

    @Test("Empty list items are skipped")
    func emptyListItems() {
        let topic = Topic("Test") {
            Description {
                """
                - Valid item
                -
                - Another valid item
                """
            }
        }

        #expect(topic.items.count >= 1)

        if case let .list(list) = topic.items[0] {
            // Should only have non-empty items
            #expect(!list.items.contains(""))
        } else {
            Issue.record("Expected list")
        }
    }

    @Test("List items with inline code")
    func listItemsWithInlineCode() {
        let topic = Topic("Test") {
            Description {
                """
                - Use `Button` for actions
                - Apply `.buttonStyle()` modifier
                - Handle `@State` changes
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .list(list) = topic.items[0] {
            #expect(list.items.count == 3)
            // Inline code should be preserved in list items
            #expect(list.items[0].contains("Button"))
        } else {
            Issue.record("Expected list")
        }
    }

    @Test("List with long multi-line items")
    func multiLineListItems() {
        let topic = Topic("Test") {
            Description {
                """
                - This is a long list item that spans multiple lines
                  and continues with proper indentation
                - Second item is shorter
                - Third item also has
                  multiple lines here
                """
            }
        }

        #expect(topic.items.count >= 1)

        if case let .list(list) = topic.items[0] {
            #expect(list.type == .unordered)
            // Should handle multi-line items
            #expect(list.items.count >= 2)
        } else {
            Issue.record("Expected list")
        }
    }

    @Test("Text with list markers that aren't lists")
    func falsePositiveListMarkers() {
        let topic = Topic("Test") {
            Description {
                """
                The range is from 1.0 to 2.5 units.
                Temperature: -5 degrees.
                Add these: 1 + 2 = 3
                """
            }
        }

        // Should not detect these as lists
        #expect(topic.items.count == 1)

        if case .description = topic.items[0] {
            // OK - correctly identified as plain text
        } else {
            Issue.record("Should not have detected lists")
        }
    }

    @Test("Bold text with inline list")
    func boldTextWithInlineList() {
        let topic = Topic("Test") {
            Description {
                """
                **Note**: Always pair with a secondary button

                **Use showCode: false when:**
                - The example is self-explanatory visually
                - Code adds no additional value
                """
            }
        }

        print("=== DEBUG: Bold text with inline list ===")
        print("Total items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .description(desc):
                print("[\(index)] Description (\(desc.value.count) chars): '\(desc.value.prefix(50))...'")
            case let .list(list):
                print("[\(index)] List (\(list.type)): \(list.items.count) items")
                for (itemIndex, listItem) in list.items.enumerated() {
                    print("  [\(itemIndex)]: '\(listItem)'")
                }
            default:
                print("[\(index)] Other: \(item)")
            }
        }

        // Should have: description with both paragraphs (**Note** and **Use showCode**), then list
        #expect(topic.items.count == 2, "Expected 2 items (description + list), got \(topic.items.count)")

        // First description should contain both Note and Use showCode with preserved markdown
        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("**Note**"))
            #expect(desc.value.contains("**Use showCode: false when:**"))
        } else {
            Issue.record("Expected first item to be description with both paragraphs")
        }

        // Second item should be the list
        if case let .list(list) = topic.items[1] {
            #expect(list.items.count == 2)
        } else {
            Issue.record("Expected second item to be list")
        }
    }
}
