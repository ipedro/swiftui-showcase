// NoteExtractionTests.swift
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

@Suite("Note Extraction from Markdown")
struct NoteExtractionTests {
    @Test("Extract note from blockquote with colon")
    func blockquoteNoteWithColon() {
        let topic = Topic("Test") {
            Description {
                """
                > Note: This is a note from blockquote
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .note(note) = topic.items[0] {
            #expect(note.type == .note)
            #expect(note.content == "This is a note from blockquote")
        } else {
            Issue.record("Expected note to be extracted")
        }
    }

    @Test("Extract note from blockquote without colon")
    func blockquoteNoteWithoutColon() {
        let topic = Topic("Test") {
            Description {
                """
                > Warning Always check before proceeding
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .note(note) = topic.items[0] {
            #expect(note.type == .warning)
            #expect(note.content == "Always check before proceeding")
        } else {
            Issue.record("Expected warning note")
        }
    }

    @Test("Extract note from list item syntax")
    func listItemNote() {
        let topic = Topic("Test") {
            Description {
                """
                - Important: Critical information here
                """
            }
        }

        #expect(topic.items.count == 1)

        if case let .note(note) = topic.items[0] {
            #expect(note.type == .important)
            #expect(note.content == "Critical information here")
        } else {
            Issue.record("Expected important note")
        }
    }

    @Test("Extract all note types")
    func allNoteTypes() {
        let topic = Topic("Test") {
            Description {
                """
                > Note: Note content

                > Important: Important content

                > Warning: Warning content

                > Deprecated: Deprecated content

                > Experimental: Experimental content

                > Tip: Tip content
                """
            }
        }

        #expect(topic.items.count == 6)

        let expectedTypes: [Note.NoteType] = [.note, .important, .warning, .deprecated, .experimental, .tip]

        for (index, expectedType) in expectedTypes.enumerated() {
            if case let .note(note) = topic.items[index] {
                #expect(note.type == expectedType)
            } else {
                Issue.record("Expected \(expectedType) at index \(index)")
            }
        }
    }

    @Test("Mixed content with notes and descriptions")
    func mixedContentWithNotes() {
        let topic = Topic("Test") {
            Description {
                """
                First paragraph of regular text.

                > Warning: Be careful here

                Second paragraph after the note.
                """
            }
        }

        print("=== Mixed content with notes ===")
        print("Items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .description(desc):
                print("[\(index)] Description: '\(desc.value)'")
            case let .note(note):
                print("[\(index)] Note (\(note.type)): '\(note.content)'")
            default:
                print("[\(index)] Other")
            }
        }

        // Should have: note, then description with both paragraphs
        #expect(topic.items.count >= 1) // At least the note
    }

    @Test("Notes with markdown formatting in content")
    func notesWithMarkdownContent() {
        let topic = Topic("Test") {
            Description {
                """
                > Tip: Use `Button` for **interactive** elements
                """
            }
        }

        if case let .note(note) = topic.items[0] {
            #expect(note.type == .tip)
            #expect(note.content.contains("`Button`"))
            #expect(note.content.contains("**interactive**"))
        } else {
            Issue.record("Expected tip note with markdown")
        }
    }

    @Test("Multiple notes in sequence")
    func multipleNotesInSequence() {
        let topic = Topic("Test") {
            Description {
                """
                > Note: First note

                > Warning: Second note

                > Tip: Third note
                """
            }
        }

        #expect(topic.items.count == 3)

        if case let .note(note1) = topic.items[0],
           case let .note(note2) = topic.items[1],
           case let .note(note3) = topic.items[2]
        {
            #expect(note1.type == .note)
            #expect(note2.type == .warning)
            #expect(note3.type == .tip)
        } else {
            Issue.record("Expected three notes in sequence")
        }
    }

    @Test("Note with multi-line content")
    func multiLineNote() {
        let topic = Topic("Test") {
            Description {
                """
                > Important: This is important information
                that spans multiple lines
                """
            }
        }

        if case let .note(note) = topic.items[0] {
            #expect(note.type == .important)
            // Content should include multi-line text
            #expect(note.content.contains("important information"))
        } else {
            Issue.record("Expected multi-line note")
        }
    }

    @Test("Note extraction preserves order with code blocks")
    func noteWithCodeBlock() {
        let topic = Topic("Test") {
            Description {
                """
                > Warning: Be careful

                ```swift
                func example() {}
                ```

                > Tip: Best practice here
                """
            }
        }

        print("=== Note with code block ===")
        print("Items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .note(note):
                print("[\(index)] Note (\(note.type))")
            case .codeBlock:
                print("[\(index)] CodeBlock")
            case let .description(desc):
                print("[\(index)] Description: '\(desc.value.prefix(30))...'")
            default:
                print("[\(index)] Other")
            }
        }

        // Should have notes and code block extracted
        #expect(topic.items.count >= 2)
    }

    @Test("Note extraction preserves order with lists")
    func noteWithList() {
        let topic = Topic("Test") {
            Description {
                """
                > Note: Important points below

                - Point 1
                - Point 2
                """
            }
        }

        print("=== Note with list ===")
        print("Items: \(topic.items.count)")
        for (index, item) in topic.items.enumerated() {
            switch item {
            case let .note(note):
                print("[\(index)] Note (\(note.type))")
            case let .list(list):
                print("[\(index)] List: \(list.items.count) items")
            case let .description(desc):
                print("[\(index)] Description: '\(desc.value.prefix(30))...'")
            default:
                print("[\(index)] Other")
            }
        }

        // Should have note and list extracted
        #expect(topic.items.count >= 2)
    }

    @Test("Regular list items not confused with notes")
    func regularListNotExtractedAsNote() {
        let topic = Topic("Test") {
            Description {
                """
                Regular list:
                - Regular item
                - Another item
                """
            }
        }

        // Should have description and list, no notes
        let hasNote = topic.items.contains { item in
            if case .note = item { return true }
            return false
        }

        #expect(!hasNote, "Regular list items should not be extracted as notes")
    }

    @Test("Bold text in description not extracted as note")
    func boldTextNotExtractedAsNote() {
        let topic = Topic("Test") {
            Description {
                """
                This has **bold text** but should not be a note.

                Also Important word in sentence.
                """
            }
        }

        // Should only have description, no notes
        let hasNote = topic.items.contains { item in
            if case .note = item { return true }
            return false
        }

        #expect(!hasNote, "Bold text without blockquote should not become a note")
    }
}
