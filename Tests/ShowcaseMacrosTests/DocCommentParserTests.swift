// DocCommentParserTests.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 10.11.25.
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

import XCTest

#if canImport(ShowcaseMacrosPlugin)
    @testable import ShowcaseMacrosPlugin
#endif

final class DocCommentParserTests: XCTestCase {
    func testParseSimpleSummary() throws {
        #if canImport(ShowcaseMacrosPlugin)
            let rawComment = "A simple button component."
            let doc = DocCommentParser.parse(rawComment)

            XCTAssertEqual(doc.summary, "A simple button component.")
            XCTAssertTrue(doc.codeBlocks.isEmpty)
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testParseSingleCodeBlock() throws {
        #if canImport(ShowcaseMacrosPlugin)
            let rawComment = """
            A customizable button component.

            ```swift
            DSButton(title: "Continue", style: .primary) {
                print("Action")
            }
            ```
            """

            let doc = DocCommentParser.parse(rawComment)

            XCTAssertEqual(doc.summary, "A customizable button component.")
            XCTAssertEqual(doc.codeBlocks.count, 1)
            XCTAssertEqual(doc.codeBlocks[0], """
            DSButton(title: "Continue", style: .primary) {
                print("Action")
            }
            """)
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testParseMultipleCodeBlocks() throws {
        #if canImport(ShowcaseMacrosPlugin)
            let rawComment = """
            A customizable button component.

            ```swift
            DSButton(title: "Save", style: .primary) {
                saveDocument()
            }
            ```

            ```swift
            DSButton(title: "Cancel", style: .secondary) {
                dismissView()
            }
            ```
            """

            let doc = DocCommentParser.parse(rawComment)

            XCTAssertEqual(doc.summary, "A customizable button component.")
            XCTAssertEqual(doc.codeBlocks.count, 2)
            XCTAssertEqual(doc.codeBlocks[0], """
            DSButton(title: "Save", style: .primary) {
                saveDocument()
            }
            """)
            XCTAssertEqual(doc.codeBlocks[1], """
            DSButton(title: "Cancel", style: .secondary) {
                dismissView()
            }
            """)
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testParseCodeBlockWithLanguageSpecifier() throws {
        #if canImport(ShowcaseMacrosPlugin)
            let rawComment = """
            Example usage:

            ```swift
            let button = DSButton(title: "Click me")
            ```
            """

            let doc = DocCommentParser.parse(rawComment)

            XCTAssertEqual(doc.summary, "Example usage:")
            XCTAssertEqual(doc.codeBlocks.count, 1)
            XCTAssertEqual(doc.codeBlocks[0], "let button = DSButton(title: \"Click me\")")
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testParseCodeBlockWithoutLanguageSpecifier() throws {
        #if canImport(ShowcaseMacrosPlugin)
            let rawComment = """
            Example:

            ```
            let value = 42
            ```
            """

            let doc = DocCommentParser.parse(rawComment)

            XCTAssertEqual(doc.summary, "Example:")
            XCTAssertEqual(doc.codeBlocks.count, 1)
            XCTAssertEqual(doc.codeBlocks[0], "let value = 42")
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testParseMixedContentWithCodeBlocks() throws {
        #if canImport(ShowcaseMacrosPlugin)
            let rawComment = """
            A versatile button.

            Basic usage:

            ```swift
            DSButton(title: "OK") { }
            ```

            Advanced usage:

            ```swift
            DSButton(title: "Submit", icon: "checkmark") {
                submitForm()
            }
            ```
            """

            let doc = DocCommentParser.parse(rawComment)

            XCTAssertEqual(doc.summary, "A versatile button.")
            XCTAssertEqual(doc.codeBlocks.count, 2)
            XCTAssertEqual(doc.codeBlocks[0], "DSButton(title: \"OK\") { }")
            XCTAssertEqual(doc.codeBlocks[1], """
            DSButton(title: "Submit", icon: "checkmark") {
                submitForm()
            }
            """)
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testParseEmptyCodeBlock() throws {
        #if canImport(ShowcaseMacrosPlugin)
            let rawComment = """
            Example:

            ```swift
            ```
            """

            let doc = DocCommentParser.parse(rawComment)

            XCTAssertEqual(doc.summary, "Example:")
            // Empty code blocks should not be added
            XCTAssertTrue(doc.codeBlocks.isEmpty)
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testParseInterleavedTextAndCodeBlocks() throws {
        #if canImport(ShowcaseMacrosPlugin)
            let rawComment = """
            A customizable button component.

            ```swift
            DSButton(title: "Continue", style: .primary) {
                print("Action")
            }
            ```

            That can also be destructive:

            ```swift
            DSButton(title: "Delete", style: .destructive) {
                print("Deleted")
            }
            ```

            And even more text after.
            """

            let doc = DocCommentParser.parse(rawComment)

            // Summary captures first paragraph
            XCTAssertEqual(doc.summary, "A customizable button component.")

            // Content parts preserve exact interleaving
            XCTAssertEqual(doc.contentParts.count, 5)

            // Part 1: Summary text
            if case let .text(text1) = doc.contentParts[0] {
                XCTAssertEqual(text1, "A customizable button component.")
            } else {
                XCTFail("Expected text part at index 0")
            }

            // Part 2: First code block
            if case let .codeBlock(code1) = doc.contentParts[1] {
                XCTAssertEqual(code1, """
                DSButton(title: "Continue", style: .primary) {
                    print("Action")
                }
                """)
            } else {
                XCTFail("Expected code block at index 1")
            }

            // Part 3: Middle text
            if case let .text(text2) = doc.contentParts[2] {
                XCTAssertTrue(text2.contains("That can also be destructive:"))
            } else {
                XCTFail("Expected text part at index 2")
            }

            // Part 4: Second code block
            if case let .codeBlock(code2) = doc.contentParts[3] {
                XCTAssertEqual(code2, """
                DSButton(title: "Delete", style: .destructive) {
                    print("Deleted")
                }
                """)
            } else {
                XCTFail("Expected code block at index 3")
            }

            // Part 5: Final text
            if case let .text(text3) = doc.contentParts[4] {
                XCTAssertTrue(text3.contains("And even more text after."))
            } else {
                XCTFail("Expected text part at index 4")
            }

            // Code blocks are still accessible via computed property
            XCTAssertEqual(doc.codeBlocks.count, 2)

            // Discussion/details still captures the text (for backward compatibility)
            XCTAssertNotNil(doc.discussion)
            XCTAssertTrue(doc.discussion?.contains("That can also be destructive:") ?? false)
            XCTAssertTrue(doc.discussion?.contains("And even more text after.") ?? false)
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
}
