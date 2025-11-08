// PerformanceTests.swift
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

/// Performance benchmarks to track optimization improvements and detect regressions.
@Suite("Performance Benchmarks", .timeLimit(.minutes(5)))
struct PerformanceTests {

    // MARK: - Test Data Generation

    static func createLargeTopic(depth: Int = 3, childrenPerLevel: Int = 5) -> Topic {
        func createChildren(currentDepth: Int) -> [Topic]? {
            guard currentDepth < depth else { return nil }
            return (0..<childrenPerLevel).map { i in
                Topic(
                    "Child \(currentDepth)-\(i)",
                    description: "Description for child \(currentDepth)-\(i) with some content",
                    code: {
                        Topic.CodeBlock("Example \(i)", text: {
                            """
                            import SwiftUI

                            struct ExampleView\(i): View {
                                var body: some View {
                                    Text("Example \(i)")
                                }
                            }
                            """
                        })
                    },
                    children: createChildren(currentDepth: currentDepth + 1)
                )
            }
        }

        return Topic(
            "Root Topic",
            description: "Root topic with nested children",
            children: createChildren(currentDepth: 0)
        )
    }

    static func createLargeDocument(chapterCount: Int = 10, topicsPerChapter: Int = 10) -> Document {
        let chapters = (0..<chapterCount).map { chapterIndex in
            let topics = (0..<topicsPerChapter).map { topicIndex in
                Topic(
                    "Topic \(chapterIndex)-\(topicIndex)",
                    description: "Description for topic \(chapterIndex)-\(topicIndex)",
                    code: {
                        Topic.CodeBlock(text: {
                            """
                            import SwiftUI

                            struct View\(chapterIndex)_\(topicIndex): View {
                                var body: some View {
                                    Text("Content")
                                }
                            }
                            """
                        })
                    }
                )
            }
            return Chapter("Chapter \(chapterIndex)") {
                for topic in topics {
                    topic
                }
            }
        }

        return Document("Performance Test Document") {
            for chapter in chapters {
                chapter
            }
        }
    }

    // MARK: - Performance Helper

    /// Measures execution time and reports if it exceeds the target threshold.
    static func measurePerformance<T>(
        _ operation: () -> T,
        iterations: Int = 10,
        targetSeconds: Double,
        file: StaticString = #filePath,
        line: Int = #line
    ) -> T {
        var result: T!
        var totalTime: Double = 0

        for _ in 0..<iterations {
            let start = CFAbsoluteTimeGetCurrent()
            result = operation()
            let end = CFAbsoluteTimeGetCurrent()
            totalTime += (end - start)
        }

        let averageTime = totalTime / Double(iterations)
        let passed = averageTime <= targetSeconds

        // Only record as issue if performance target not met
        if !passed {
            Issue.record(
                Comment(rawValue: """
                    Performance FAILED: \(String(format: "%.6f", averageTime))s (target: \(String(format: "%.6f", targetSeconds))s)
                    """),
                sourceLocation: SourceLocation(
                    fileID: file.description,
                    filePath: file.description,
                    line: line,
                    column: 0
                )
            )
        }

        // Print performance metrics for passing tests too (visible in verbose output)
        print("⏱️  Performance: \(String(format: "%.6f", averageTime))s (target: \(String(format: "%.6f", targetSeconds))s) [\(passed ? "✓" : "✗")]")

        return result
    }

    // MARK: - Benchmark Tests

    @Test("allChildren performance in deep hierarchy")
    func allChildrenPerformance() {
        let topic = Self.createLargeTopic(depth: 3, childrenPerLevel: 5)

        // Target: < 0.01 seconds for 3-level tree with 125 total nodes
        _ = Self.measurePerformance({ topic.allChildren }, targetSeconds: 0.01)
    }

    @Test("withIcon propagation performance")
    func withIconPerformance() {
        let topic = Self.createLargeTopic(depth: 3, childrenPerLevel: 5)
        let icon = Image(systemName: "star")

        // Target: < 0.05 seconds with early-exit optimization
        _ = Self.measurePerformance({ topic.withIcon(icon) }, targetSeconds: 0.05)
    }

    @Test("withIcon early exit performance")
    func withIconEarlyExitPerformance() {
        let iconTopic = Self.createLargeTopic(depth: 3, childrenPerLevel: 5)
            .withIcon(Image(systemName: "star"))
        let newIcon = Image(systemName: "circle")

        // Target: < 0.001 seconds (should be nearly instant)
        _ = Self.measurePerformance({ iconTopic.withIcon(newIcon) }, targetSeconds: 0.001)
    }

    @Test("Topic search performance")
    func topicSearchPerformance() {
        let topic = Self.createLargeTopic(depth: 3, childrenPerLevel: 5)
        let query = "Child 2-3"

        // Target: < 0.02 seconds for 125 topics
        _ = Self.measurePerformance({ topic.search(query: query) }, targetSeconds: 0.02)
    }

    @Test("Search short-circuit performance")
    func topicSearchShortCircuitPerformance() {
        let topic = Self.createLargeTopic(depth: 3, childrenPerLevel: 5)
        let query = "Root Topic" // Matches title immediately

        // Target: < 0.005 seconds with short-circuit optimization
        _ = Self.measurePerformance({ topic.search(query: query) }, targetSeconds: 0.005)
    }

    @Test("Chapter search performance")
    func chapterSearchPerformance() {
        let topics = (0..<100).map { i in
            Topic("Topic \(i)") {
                Description("Description for topic \(i)")
                Topic.CodeBlock(text: { "func example\(i)() {}" })
            }
        }
        let chapter = Chapter("Test Chapter") {
            for topic in topics {
                topic
            }
        }
        let query = "Topic 50"

        // Target: < 0.03 seconds for 100 topics
        _ = Self.measurePerformance({ chapter.search(query: query) }, targetSeconds: 0.03)
    }

    @Test("Document search performance")
    func documentSearchPerformance() {
        let document = Self.createLargeDocument(chapterCount: 100, topicsPerChapter: 10)
        let query = "Topic 50-5"

        // Target: < 0.1 seconds for 100 chapters with 10 topics each
        _ = Self.measurePerformance({ document.chapters.search(query) }, targetSeconds: 0.1)
    }

    @Test("isEmpty check performance")
    func isEmptyPerformance() {
        let topics = [
            Topic("Empty"),
            Topic("With Description") {
                Description("Some content")
            },
            Topic("With Code") {
                Topic.CodeBlock(text: { "func test() {}" })
            },
            Topic("With Children") {
                Topic("Child") {
                    Description("Child content")
                }
            }
        ]

        // Target: < 0.001 seconds (should short-circuit quickly)
        _ = Self.measurePerformance({ topics.map { $0.isEmpty } }, targetSeconds: 0.001)
    }

    @Test("Topic sorting performance")
    func topicSortingPerformance() {
        let topics = (0..<1000).shuffled().map { i in
            Topic("Topic \(String(format: "%04d", i))")
        }

        // Target: < 0.05 seconds for 1000 topics
        _ = Self.measurePerformance({ topics.sorted() }, targetSeconds: 0.05)
    }

    @Test("Hashable operations performance")
    func hashablePerformance() {
        let topics = (0..<1000).map { i in
            Topic("Topic \(i)")
        }

        // Target: < 0.01 seconds for 1000 hash operations
        _ = Self.measurePerformance({
            var set = Set<Topic>()
            for topic in topics {
                set.insert(topic)
            }
            return set
        }, targetSeconds: 0.01)
    }

    @Test("Lazy property caching performance")
    func lazyPropertyPerformance() {
        let topic = Topic("Test") {
            Description("A very long description " + String(repeating: "that repeats ", count: 100))
            Topic.CodeBlock(text: { String(repeating: "Line 0\n", count: 50) })
            Topic.CodeBlock(text: { String(repeating: "Line 1\n", count: 50) })
            Topic.CodeBlock(text: { String(repeating: "Line 2\n", count: 50) })
            Topic.CodeBlock(text: { String(repeating: "Line 3\n", count: 50) })
            Topic.CodeBlock(text: { String(repeating: "Line 4\n", count: 50) })
        }

        // Target: < 0.001 seconds (properties should only init once)
        _ = Self.measurePerformance({
            // Access properties multiple times - should be cached
            for _ in 0..<100 {
                _ = topic.description
                _ = topic.codeBlocks
            }
        }, targetSeconds: 0.001)
    }

    @Test("withIcon memory efficiency")
    func withIconMemoryEfficiency() {
        let topic = Self.createLargeTopic(depth: 3, childrenPerLevel: 5)
        let icon = Image(systemName: "star")

        _ = Self.measurePerformance({
            // First application - should create copies
            let topicWithIcon = topic.withIcon(icon)

            // Second application - should early exit (no copies)
            _ = topicWithIcon.withIcon(Image(systemName: "circle"))
        }, targetSeconds: 0.001)
    }
}
