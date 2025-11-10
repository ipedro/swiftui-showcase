// NoteTests.swift
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

@Suite("Note Component")
struct NoteTests {
    @Test("Note can be created with different types")
    func noteTypes() {
        for type in Note.NoteType.allCases {
            let note = Note(type) { "Test content" }
            #expect(note.type == type)
            #expect(note.content == "Test content")
        }
    }

    @Test("Note defaults to .note type")
    func defaultType() {
        let note = Note { "Default note" }
        #expect(note.type == .note)
    }

    @Test("Note integrates with Topic content")
    func noteInTopic() {
        let topic = Topic("Test") {
            Description { "Introduction" }
            Note(.warning) { "Be careful!" }
            Description { "More content" }
        }

        #expect(topic.items.count == 3)

        if case .description = topic.items[0],
           case let .note(note) = topic.items[1],
           case .description = topic.items[2] {
            #expect(note.type == .warning)
            #expect(note.content == "Be careful!")
        } else {
            Issue.record("Expected description, note, description")
        }
    }

    @Test("Multiple notes maintain order")
    func multipleNotes() {
        let topic = Topic("Test") {
            Note(.note) { "Note 1" }
            Note(.warning) { "Note 2" }
            Note(.important) { "Note 3" }
        }

        #expect(topic.items.count == 3)

        for (index, item) in topic.items.enumerated() {
            guard case .note = item else {
                Issue.record("Expected all items to be notes")
                return
            }
        }
    }

    @Test("Note type has correct titles")
    func noteTypeTitles() {
        #expect(Note.NoteType.note.title == "Note")
        #expect(Note.NoteType.warning.title == "Warning")
        #expect(Note.NoteType.important.title == "Important")
        #expect(Note.NoteType.deprecated.title == "Deprecated")
        #expect(Note.NoteType.experimental.title == "Experimental")
        #expect(Note.NoteType.tip.title == "Tip")
    }

    @Test("Note is searchable")
    func noteSearch() {
        let topic = Topic("Test") {
            Description { "Regular text" }
            Note(.warning) { "Deprecated API warning" }
        }

        // Should find by note content
        let result1 = topic.search(query: "deprecated")
        #expect(result1 != nil)

        // Should find by note type
        let result2 = topic.search(query: "warning")
        #expect(result2 != nil)

        // Should not find unrelated text
        let result3 = topic.search(query: "nonexistent")
        #expect(result3 == nil)
    }

    @Test("Notes are equatable and hashable")
    func noteEquality() {
        let note1 = Note(.warning) { "Same content" }
        let note2 = Note(.warning) { "Same content" }
        let note3 = Note(.note) { "Different content" }

        #expect(note1 == note2)
        #expect(note1 != note3)

        // Test hashability
        let set: Set<Note> = [note1, note2, note3]
        #expect(set.count == 2) // note1 and note2 are equal
    }

    @Test("Note with markdown formatting")
    func noteWithMarkdown() {
        let note = Note(.tip) {
            "Use **bold** and `code` in notes"
        }

        #expect(note.content.contains("**bold**"))
        #expect(note.content.contains("`code`"))
    }
}
