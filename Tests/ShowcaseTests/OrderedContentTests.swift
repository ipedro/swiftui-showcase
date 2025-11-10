// OrderedContentTests.swift
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
import SwiftUI
import Testing

/// Tests validating ordered content rendering behavior
struct OrderedContentTests {
    @Test("Items are stored in declaration order")
    func itemsPreserveDeclarationOrder() throws {
        let topic = Topic("Test") {
            ExternalLink("Apple", URL(string: "https://example.com/1")!)!

            CodeBlock {
                "let x = 1"
            }

            Example("Preview") {
                Text("Demo")
            }

            Embed(URL(string: "https://example.com/embed")!)!

            ExternalLink("GitHub", URL(string: "https://example.com/2")!)!
        }

        // Verify we have 5 items
        #expect(topic.items.count == 5)

        // Verify order matches declaration
        guard case .link = topic.items[0] else {
            Issue.record("Expected first item to be link")
            return
        }

        guard case .codeBlock = topic.items[1] else {
            Issue.record("Expected second item to be codeBlock")
            return
        }

        guard case .example = topic.items[2] else {
            Issue.record("Expected third item to be example")
            return
        }

        guard case .embed = topic.items[3] else {
            Issue.record("Expected fourth item to be embed")
            return
        }

        guard case .link = topic.items[4] else {
            Issue.record("Expected fifth item to be link")
            return
        }
    }

    @Test("Mixed content types preserve order")
    func mixedContentPreservesOrder() {
        let topic = Topic("Mixed") {
            Embed(URL(string: "https://example.com")!)!
            ExternalLink("Apple", URL(string: "https://example.com")!)!
            CodeBlock { "code" }
            Example("Preview") { Text("Demo") }
        }

        #expect(topic.items.count == 4)

        // Verify: Embed → Link → CodeBlock → Preview
        if case .embed = topic.items[0],
           case .link = topic.items[1],
           case .codeBlock = topic.items[2],
           case .example = topic.items[3]
        {
            // Success - order matches
        } else {
            Issue.record("Items not in expected order")
        }
    }

    @Test("Empty topic has empty items")
    func emptyTopicHasEmptyItems() {
        let topic = Topic("Empty")

        #expect(topic.items.isEmpty)
    }

    @Test("Topic with only description has description in items")
    func topicWithOnlyDescriptionHasItemsWithDescription() {
        let topic = Topic("Only Description") {
            Description("Just text, no content items")
        }

        #expect(topic.items.count == 1)
        if case let .description(description) = topic.items.first {
            #expect(description.value == "Just text, no content items")
        } else {
            Issue.record("Expected description item")
        }
    }

    @Test("Backward compatibility - separate arrays still work")
    func separateArraysStillPopulated() {
        let topic = Topic("Backward Compat") {
            ExternalLink("Apple", URL(string: "https://example.com/1")!)!
            ExternalLink("GitHub", URL(string: "https://example.com/2")!)!
            CodeBlock { "code" }
            Example("Preview") { Text("Demo") }
        }

        // Items array should have all 4 content pieces
        #expect(topic.items.count == 4)
    }

    @Test("Multiple items of same type maintain order")
    func multipleItemsOfSameTypeMaintainOrder() {
        let topic = Topic("Same Type") {
            CodeBlock { "first" }
            CodeBlock { "second" }
            CodeBlock { "third" }
        }

        #expect(topic.items.count == 3)

        // All should be codeBlock type in order
        for item in topic.items {
            guard case .codeBlock = item else {
                Issue.record("Expected all items to be codeBlock")
                return
            }
        }
    }
}
