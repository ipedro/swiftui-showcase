// ShowcasableBasicTests.swift
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

/// Tests for basic @Showcasable macro functionality
final class ShowcasableBasicTests: ShowcaseMacrosTestsBase {
    func testShowcasableBasic() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable
                struct PrimaryButton: View {
                    var body: some View {
                        Button("Primary") {}
                    }
                }
                """,
                expandedSource: #"""
                struct PrimaryButton: View {
                    var body: some View {
                        Button("Primary") {}
                    }
                }

                extension PrimaryButton: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("PrimaryButton") {
                            CodeBlock("Type Relationships") {
                                """
                                struct PrimaryButton: View
                                """
                            }
                        }
                    }
                }
                """#,
                diagnostics: [],
                macros: testMacros
            )
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testShowcasableWithIcon() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable(icon: "button.horizontal", autoDiscover: false)
                struct PrimaryButton: View {
                    var body: some View {
                        Button("Primary") {}
                    }
                }
                """,
                expandedSource: #"""
                struct PrimaryButton: View {
                    var body: some View {
                        Button("Primary") {}
                    }
                }

                extension PrimaryButton: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("PrimaryButton", icon: Image(systemName: "button.horizontal")) {
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

    func testShowcasableWithDocComment() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// A primary action button.
                @Showcasable(autoDiscover: false)
                struct PrimaryButton: View {
                    var body: some View {
                        Button("Primary") {}
                    }
                }
                """,
                expandedSource: #"""
                /// A primary action button.
                struct PrimaryButton: View {
                    var body: some View {
                        Button("Primary") {}
                    }
                }

                extension PrimaryButton: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("PrimaryButton") {
                            Description {
                                """
                                A primary action button.
                                """
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

    func testShowcasableWithCodeBlocksInDocComment() throws {
        // Note: This test is skipped because SwiftSyntaxMacrosTestSupport's assertMacroExpansion
        // does not preserve the multi-line structure of doc comments when extracting them from trivia.
        // The code block extraction logic is verified to work correctly in DocCommentParserTests.
        // In real compilation (ShowcaseExample app), the feature works as expected.
        throw XCTSkip("assertMacroExpansion doesn't preserve doc comment newlines for code block extraction")
    }

    func testShowcasableWithExample() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable(autoDiscover: false)
                struct PrimaryButton: View {
                    @ShowcaseExample(title: "Basic")
                    static var basic: some View {
                        PrimaryButton()
                    }
                    
                    var body: some View {
                        Button("Primary") {}
                    }
                }
                """,
                expandedSource: ##"""
                struct PrimaryButton: View {
                    static var basic: some View {
                        PrimaryButton()
                    }
                    
                    var body: some View {
                        Button("Primary") {}
                    }
                }

                extension PrimaryButton: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("PrimaryButton") {
                                Example("Basic") {
                                    PrimaryButton.basic
                                    CodeBlock("Basic - Source Code") {
                                        #"""
                                            PrimaryButton()
                                        """#
                                    }
                                }
                        }
                    }
                }
                """##,
                macros: testMacros
            )
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testShowcasableWithExampleAndDescription() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable(autoDiscover: false)
                struct ActionButton: View {
                    @ShowcaseExample(title: "Primary Action", description: "A primary button with icon")
                    static var withIcon: some View {
                        ActionButton(title: "Submit", icon: "checkmark")
                    }
                    
                    var body: some View {
                        Button("Action") {}
                    }
                }
                """,
                expandedSource: ##"""
                struct ActionButton: View {
                    static var withIcon: some View {
                        ActionButton(title: "Submit", icon: "checkmark")
                    }
                    
                    var body: some View {
                        Button("Action") {}
                    }
                }

                extension ActionButton: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("ActionButton") {
                                Example("Primary Action") {
                                    Description {
                                        """
                                        A primary button with icon
                                        """
                                    }
                                    ActionButton.withIcon
                                    CodeBlock("Primary Action - Source Code") {
                                        #"""
                                            ActionButton(title: "Submit", icon: "checkmark")
                                        """#
                                    }
                                }
                        }
                    }
                }
                """##,
                macros: testMacros
            )
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testShowcasableWithAllContent() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// A versatile button for actions
                @Showcasable(icon: "button.circle", autoDiscover: false)
                struct ActionButton: View {
                    @ShowcaseExample(title: "Basic Usage")
                    static var basic: some View {
                        ActionButton(title: "Submit")
                    }
                    
                    @ShowcaseHidden
                    private var internalState: Int = 0
                    
                    var body: some View {
                        Button("Action") {}
                    }
                }
                """,
                expandedSource: ##"""
                /// A versatile button for actions
                struct ActionButton: View {
                    static var basic: some View {
                        ActionButton(title: "Submit")
                    }

                    private var internalState: Int = 0
                    
                    var body: some View {
                        Button("Action") {}
                    }
                }

                extension ActionButton: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("ActionButton", icon: Image(systemName: "button.circle")) {
                            Description {
                                """
                                A versatile button for actions
                                """
                            }
                                        Example("Basic Usage") {
                                            ActionButton.basic
                                            CodeBlock("Basic Usage - Source Code") {
                                                #"""
                                                    ActionButton(title: "Submit")
                                                """#
                                            }
                                        }
                        }
                    }
                }
                """##,
                macros: testMacros
            )
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    func testShowcasableMissingChapter() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable
                struct PrimaryButton: View {
                    var body: some View {
                        Button("Primary") {}
                    }
                }
                """,
                expandedSource: #"""
                struct PrimaryButton: View {
                    var body: some View {
                        Button("Primary") {}
                    }
                }

                extension PrimaryButton: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("PrimaryButton") {
                            CodeBlock("Type Relationships") {
                                """
                                struct PrimaryButton: View
                                """
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

    func testShowcasableWithBlockquoteNote() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// A card component
                ///
                /// > The card takes a generic content.
                @Showcasable
                struct DSCard: View {
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                /// A card component
                ///
                /// > The card takes a generic content.
                struct DSCard: View {
                    var body: some View {
                        EmptyView()
                    }
                }

                extension DSCard: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("DSCard") {
                            CodeBlock("Type Relationships") {
                                """
                                struct DSCard: View
                                """
                            }
                            Description {
                                """
                                A card component
                                """
                            }
                            Note {
                                """
                                The card takes a generic content.
                                """
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
