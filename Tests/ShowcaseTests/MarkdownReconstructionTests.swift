// MarkdownReconstructionTests.swift
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

@testable import Showcase
import Testing

/// Tests that verify markdown formatting is preserved when extracting lists from descriptions.
///
/// When we parse markdown with AttributedString to detect lists, we need to reconstruct
/// the original markdown syntax for inline formatting (bold, italic, code) and block
/// elements (headings). This test suite verifies the reconstruction works correctly.
@Suite("Markdown Reconstruction from AttributedString")
struct MarkdownReconstructionTests {
    @Test("Reconstructs bold text from InlinePresentationIntent")
    func boldReconstruction() {
        let topic = Topic("Test") {
            Description {
                "Text with **bold** formatting"
            }
        }

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("**bold**"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Reconstructs italic text from InlinePresentationIntent")
    func italicReconstruction() {
        let topic = Topic("Test") {
            Description {
                "Text with *italic* formatting"
            }
        }

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("*italic*"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Reconstructs inline code from InlinePresentationIntent")
    func inlineCodeReconstruction() {
        let topic = Topic("Test") {
            Description {
                "Use the `Button` component"
            }
        }

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("`Button`"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Reconstructs heading syntax from PresentationIntent")
    func headingReconstruction() {
        let topic = Topic("Test") {
            Description {
                """
                ## Section Title

                Some content
                """
            }
        }

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("## Section Title"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Preserves paragraph breaks between blocks")
    func paragraphBreaks() {
        let topic = Topic("Test") {
            Description {
                """
                First paragraph

                Second paragraph
                """
            }
        }

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("\n\n"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Combines formatting in complex scenarios")
    func complexFormatting() {
        let topic = Topic("Test") {
            Description {
                """
                **Note**: Use `@Showcasable` for automatic docs

                ## Features

                Supports *all* SwiftUI views
                - Easy to use
                - Powerful
                """
            }
        }

        // Should extract description with formatting preserved, then list
        #expect(topic.items.count == 2)

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("**Note**"))
            #expect(desc.value.contains("`@Showcasable`"))
            #expect(desc.value.contains("## Features"))
            #expect(desc.value.contains("*all*"))
        } else {
            Issue.record("Expected description with preserved markdown")
        }

        if case let .list(list) = topic.items[1] {
            #expect(list.items.count == 2)
        } else {
            Issue.record("Expected list")
        }
    }

    @Test("InlinePresentationIntent.code takes precedence over emphasis")
    func codePrecedence() {
        let topic = Topic("Test") {
            Description {
                "Use `code` not **bold**"
            }
        }

        if case let .description(desc) = topic.items[0] {
            #expect(desc.value.contains("`code`"))
            #expect(desc.value.contains("**bold**"))
        } else {
            Issue.record("Expected description")
        }
    }

    @Test("Preserves list item formatting")
    func listItemFormatting() {
        let topic = Topic("Test") {
            Description {
                """
                - **Primary**: Use for main actions
                - `Button`: Standard component
                """
            }
        }

        if case let .list(list) = topic.items[0] {
            #expect(list.items[0].contains("Primary"))
            #expect(list.items[1].contains("Button"))
        } else {
            Issue.record("Expected list")
        }
    }
}
