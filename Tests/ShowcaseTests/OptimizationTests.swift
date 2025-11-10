// OptimizationTests.swift
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

/// Unit tests validating the behavior of performance optimizations.
@Suite("Optimization Tests")
struct OptimizationTests {
    // MARK: - Lazy Property Wrapper Tests

    @Suite("Lazy Property Wrapper")
    struct LazyPropertyTests {
        @Test("Thread safety with concurrent access")
        func threadSafety() async {
            let callCounter = CallCounter()
            let lazy = Lazy(wrappedValue: {
                callCounter.increment()
                return "Value"
            }())

            // Simulate concurrent access
            await withTaskGroup(of: Void.self) { group in
                for _ in 0 ..< 100 {
                    group.addTask {
                        _ = lazy.wrappedValue
                    }
                }
                await group.waitForAll()
            }

            // The closure should only be called once despite concurrent access
            #expect(callCounter.count == 1, "Lazy closure should only execute once")
        }
    }

    // Helper class for thread-safe counting
    private final class CallCounter: @unchecked Sendable {
        private let lock = NSLock()
        private var _count = 0

        var count: Int {
            lock.lock()
            defer { lock.unlock() }
            return _count
        }

        func increment() {
            lock.lock()
            defer { lock.unlock() }
            _count += 1
        }

        @Test("Caching behavior across multiple accesses")
        func caching() {
            let callCounter = CallCounter()
            let lazy = Lazy(wrappedValue: {
                callCounter.increment()
                return "Cached Value"
            }())

            // Access multiple times
            #expect(lazy.wrappedValue == "Cached Value")
            #expect(lazy.wrappedValue == "Cached Value")
            #expect(lazy.wrappedValue == "Cached Value")

            #expect(callCounter.count == 1, "Lazy property should cache the value")
        }
    }

    // MARK: - withIcon Early Exit Tests

    @Suite("withIcon Early Exit Optimization")
    struct WithIconTests {
        @Test("Early exit when proposal is nil")
        func earlyExitWithNilProposal() {
            let original = Topic("Test") {
                Description("Original")
            }
            let result = original.withIcon(nil)

            // Should return the same instance (identity equality)
            #expect(original.id == result.id)
        }

        @Test("Early exit when topic already has icon")
        func earlyExitWithExistingIcon() {
            let icon1 = Image(systemName: "star")
            let icon2 = Image(systemName: "circle")

            let topicWithIcon = Topic("Test", icon: icon1) {
                Description("Has icon")
            }
            let result = topicWithIcon.withIcon(icon2)

            // Should return self without modification
            #expect(topicWithIcon.id == result.id)
            // Original icon should be preserved
            #expect(result.icon != nil)
        }

        @Test("Applies icon when topic has no icon")
        func appliesWhenNoIcon() {
            let icon = Image(systemName: "star")
            let topic = Topic("Test") {
                Description("No icon")
            }

            #expect(topic.icon == nil)

            let result = topic.withIcon(icon)

            #expect(result.icon != nil)
        }

        @Test("Icon propagates to children")
        func propagationToChildren() {
            let icon = Image(systemName: "star")
            let child = Topic("Child")
            let parent = Topic("Parent") {
                child
            }

            let result = parent.withIcon(icon)

            #expect(result.icon != nil)
            #expect(result.children?.first?.icon != nil)
        }

        @Test("Chapter with icon early exit")
        func chapterWithIcon() {
            let icon1 = Image(systemName: "star")
            let icon2 = Image(systemName: "circle")

            let chapterWithIcon = Chapter("Test") {
                Icon(icon1)
                Topic("Topic1")
            }
            let result = chapterWithIcon.withIcon(icon2)

            // Should preserve original icon
            #expect(result.icon != nil)
        }
    }

    // MARK: - allChildren Tests

    @Suite("allChildren Flattening")
    struct AllChildrenTests {
        @Test("Empty when no children")
        func emptyWhenNoChildren() {
            let topic = Topic("Root")
            #expect(topic.allChildren.isEmpty)
        }

        @Test("Flattens hierarchy correctly")
        func flattensHierarchy() {
            let grandchild = Topic("Grandchild")
            let child = Topic("Child") {
                grandchild
            }
            let root = Topic("Root") {
                child
            }

            let allChildren = root.allChildren

            #expect(allChildren.count == 2)
            #expect(allChildren.contains { $0.title == "Child" })
            #expect(allChildren.contains { $0.title == "Grandchild" })
        }

        @Test("Deep hierarchy performance")
        func deepHierarchy() {
            // Create a deep hierarchy: Root -> L1 -> L2 -> L3
            let l3 = Topic("Level3")
            let l2 = Topic("Level2") { l3 }
            let l1 = Topic("Level1") { l2 }
            let root = Topic("Root") { l1 }

            let allChildren = root.allChildren

            // Should contain all 3 levels
            #expect(allChildren.count == 3)
        }
    }

    // MARK: - isEmpty Tests

    @Suite("isEmpty Short-Circuit Checks")
    struct IsEmptyTests {
        @Test("Empty with no content")
        func emptyWithNoContent() {
            let topic = Topic("Test")
            #expect(topic.isEmpty)
        }

        @Test("Not empty with description")
        func notEmptyWithDescription() {
            let topic = Topic("Test") {
                Description("Has content")
            }
            #expect(!topic.isEmpty)
        }

        @Test("Not empty with code blocks")
        func notEmptyWithCodeBlocks() {
            let topic = Topic("Test") {
                CodeBlock("Example")
            }
            #expect(!topic.isEmpty)
        }

        @Test("Not empty with previews")
        func notEmptyWithPreviews() {
            let topic = Topic("Test") {
                Example { Text("Preview") }
            }
            #expect(!topic.isEmpty)
        }

        @Test("Not empty with children")
        func notEmptyWithChildren() {
            let topic = Topic("Test") {
                Topic("Child")
            }
            #expect(!topic.isEmpty)
        }

        @Test("Not empty with links")
        func notEmptyWithLinks() {
            let topic = Topic("Test") {
                ExternalLink("Documentation", "https://example.com")
            }
            #expect(!topic.isEmpty)
        }

        @Test("Not empty with embeds")
        func notEmptyWithEmbeds() {
            guard let embed = Embed(URL(string: "https://example.com")!) else {
                Issue.record("Failed to create embed")
                return
            }
            let topic = Topic("Test") {
                embed
            }
            #expect(!topic.isEmpty)
        }
    }

    // MARK: - Search Short-Circuit Tests

    @Suite("Search Short-Circuit")
    struct SearchTests {
        @Test("Short-circuits on title match")
        func shortCircuitsOnTitleMatch() {
            let topic = Topic("MatchThis") {
                Description("Description")
            }

            let result = topic.search(query: "MatchThis")

            // Should find match in title immediately without checking other properties
            #expect(result != nil)
        }

        @Test("Returns nil when no match")
        func returnsNilWhenNoMatch() {
            let topic = Topic("Test") {
                Description("Content")
            }

            let result = topic.search(query: "NotFound")

            #expect(result == nil)
        }

        @Test("Matches in code blocks")
        func matchesInCodeBlocks() {
            let topic = Topic("Test") {
                CodeBlock("Example", text: { "func hello() {}" })
            }

            let result = topic.search(query: "hello")

            #expect(result != nil)
        }

        @Test("Matches in links")
        func matchesInLinks() {
            let topic = Topic("Test") {
                ExternalLink("Documentation", "https://example.com/special")
            }

            let result = topic.search(query: "special")

            #expect(result != nil)
        }

        @Test("Chapter search returns matching topics")
        func chapterSearchReturnsMatchingTopics() {
            let topic1 = Topic("Match1") {
                Description("first")
            }
            let topic2 = Topic("Different") {
                Description("second")
            }
            let topic3 = Topic("Match2") {
                Description("third")
            }
            let chapter = Chapter("Test") {
                topic1
                topic2
                topic3
            }

            let result = chapter.search(query: "atch")

            #expect(result != nil)
            // Should only return topics with "atch" in title (Match1 and Match2)
            #expect(result?.topics.count == 2, "Expected 2 topics with 'atch', got \(result?.topics.map { $0.title } ?? [])")
        }
    }

    // MARK: - Hashable Protocol Tests

    @Suite("Hashable Protocol Conformance")
    struct HashableTests {
        @Test("Topic instances have unique hashes")
        func topicHashable() {
            let topic1 = Topic("Test")
            let topic2 = Topic("Test")

            // Different instances should have different hashes (ID-based)
            #expect(topic1.hashValue != topic2.hashValue)

            // Same instance should have same hash
            #expect(topic1.hashValue == topic1.hashValue)
        }

        @Test("Topic equality is ID-based")
        func topicEquality() {
            let topic1 = Topic("Test")
            let topic2 = topic1

            #expect(topic1 == topic2)
        }

        @Test("Chapter instances have unique hashes")
        func chapterHashable() {
            let chapter1 = Chapter("Test") {
                Topic("Topic1")
            }
            let chapter2 = Chapter("Test") {
                Topic("Topic1")
            }

            // Different instances should have different hashes
            #expect(chapter1.hashValue != chapter2.hashValue)

            var set = Set<Chapter>()
            set.insert(chapter1)
            set.insert(chapter2)

            #expect(set.count == 2)
        }

        @Test("Document instances have unique hashes")
        func documentHashable() {
            let doc1 = Document("Doc1") {
                Chapter("Ch1") {
                    Topic("T1")
                }
            }
            let doc2 = Document("Doc2") {
                Chapter("Ch1") {
                    Topic("T1")
                }
            }

            // Different instances should have different hashes
            #expect(doc1.hashValue != doc2.hashValue)

            var set = Set<Document>()
            set.insert(doc1)
            set.insert(doc2)

            #expect(set.count == 2)
        }

        @Test("CodeBlock equality is ID-based")
        func codeBlockEquality() {
            let block1 = CodeBlock("Example", text: { "code" })
            let block2 = CodeBlock("Example", text: { "code" })

            // CodeBlocks use ID-based equality (different instances = different IDs)
            #expect(block1 != block2)
            #expect(block1 == block1) // Same instance is equal to itself
        }

        @Test("CodeBlock instances have unique hashes")
        func codeBlockHashable() {
            let block1 = CodeBlock("Example", text: { "code" })
            let block2 = CodeBlock("Example", text: { "code" })

            var set = Set<CodeBlock>()
            set.insert(block1)
            set.insert(block2)

            // Different instances have different IDs, so both are stored
            #expect(set.count == 2)
        }

        @Test("Link instances have unique hashes")
        func linkHashable() {
            guard let link1 = ExternalLink("Documentation", "https://example.com"),
                  let link2 = ExternalLink("Documentation", "https://example.com")
            else {
                Issue.record("Failed to create links")
                return
            }

            var set = Set<ExternalLink>()
            set.insert(link1)
            set.insert(link2)

            // Different instances have different IDs, so both are stored
            #expect(set.count == 2)
        }
    }
}
