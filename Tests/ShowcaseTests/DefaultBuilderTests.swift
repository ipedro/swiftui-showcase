// DefaultBuilderTests.swift
// Copyright (c) 2025 Pedro Almeida
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

import Testing
import SwiftUI
@testable import Showcase

@Suite("Default Builder Parameter Tests")
struct DefaultBuilderTests {

    @Test("Topic with no content closure")
    func topicWithoutBraces() {
        let topic = Topic("Test Topic")

        #expect(topic.title == "Test Topic")
        #expect(topic.description == "")
        #expect(topic.codeBlocks.isEmpty)
        #expect(topic.links.isEmpty)
        #expect(topic.embeds.isEmpty)
        #expect(topic.previews.isEmpty)
        #expect(topic.children == nil)
    }

    @Test("Topic with icon and no content closure")
    func topicWithIconWithoutBraces() {
        let icon = Image(systemName: "star")
        let topic = Topic("Test Topic", icon: icon)

        #expect(topic.title == "Test Topic")
        #expect(topic.icon != nil)
        #expect(topic.description == "")
        #expect(topic.codeBlocks.isEmpty)
    }

    @Test("Chapter with no content closure")
    func chapterWithoutBraces() {
        let chapter = Chapter("Test Chapter")

        #expect(chapter.title == "Test Chapter")
        #expect(chapter.description == "")
        #expect(chapter.topics.isEmpty)
    }

    @Test("Chapter with icon and no content closure")
    func chapterWithIconWithoutBraces() {
        let icon = Image(systemName: "book")
        let chapter = Chapter("Test Chapter", icon: icon)

        #expect(chapter.title == "Test Chapter")
        #expect(chapter.icon != nil)
        #expect(chapter.description == "")
        #expect(chapter.topics.isEmpty)
    }

    @Test("Document with no content closure")
    func documentWithoutBraces() {
        let document = Document("Test Document") {}

        #expect(document.title == "Test Document")
        #expect(document.description == "")
        #expect(document.chapters.isEmpty)
    }

    @Test("Document with description and no content closure")
    func documentWithDescriptionWithoutBraces() {
        let document = Document("Test Document", description: "A test") {}

        #expect(document.title == "Test Document")
        #expect(document.description == "A test")
        #expect(document.chapters.isEmpty)
    }

    @Test("Document with icon and no content closure")
    func documentWithIconWithoutBraces() {
        let icon = Image(systemName: "doc")
        let document = Document("Test Document", icon: icon) {}

        #expect(document.title == "Test Document")
        #expect(document.icon != nil)
        #expect(document.chapters.isEmpty)
    }
}
