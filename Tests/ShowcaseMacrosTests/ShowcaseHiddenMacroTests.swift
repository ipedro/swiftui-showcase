// ShowcaseHiddenMacroTests.swift
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

import SwiftSyntaxMacrosTestSupport
import XCTest

/// Tests for @ShowcaseHidden macro functionality
final class ShowcaseHiddenMacroTests: ShowcaseMacrosTestsBase {
    func testShowcaseHiddenMacro() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable(chapter: "Models", autoDiscover: true)
                struct User {
                    var name: String
                    
                    @ShowcaseHidden
                    private var internalCache: [String: Any]
                }
                """,
                expandedSource: #"""
                struct User {
                    var name: String

                    private var internalCache: [String: Any]
                }

                extension User: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("User") {
                            Topic("name") {
                                CodeBlock("Declaration") {
                                    """
                                    var name: String
                                    """
                                }
                            }
                        }
                    }
                }
                """#,
                macros: testMacros
            )
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
}
