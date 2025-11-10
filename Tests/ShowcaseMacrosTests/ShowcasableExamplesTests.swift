// ShowcasableExamplesTests.swift
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

/// Tests for @Showcasable macro's examples parameter functionality
final class ShowcasableExamplesTests: ShowcaseMacrosTestsBase {
    func testShowcasableWithExternalExamples() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable(examples: [CardExamples.self])
                struct Card<Content: View>: View {
                    let content: Content
                    var body: some View { content }
                    
                    struct CardExamples {
                        @ShowcaseExample(title: "Basic Card")
                        static var basic: Card<Text> {
                            Card(content: Text("Hello"))
                        }
                    }
                }
                """,
                expandedSource: ##"""
                struct Card<Content: View>: View {
                    let content: Content
                    var body: some View { content }
                    
                    struct CardExamples {
                        static var basic: Card<Text> {
                            Card(content: Text("Hello"))
                        }
                    }
                }

                extension Card: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("Card") {
                            CodeBlock("Type Relationships") {
                                """
                                struct Card<Content: View>: View
                                """
                            }
                            Topic("content") {
                                CodeBlock("Declaration") {
                                    """
                                    var content: Content
                                    """
                                }
                            }
                                    ExampleGroup("Examples") {
                                                Example("Basic Card") {
                                                    Card.basic
                                                    CodeBlock("Basic Card - Source Code") {
                                                        #"""
                                                            Card(content: Text("Hello"))
                                                        """#
                                                    }
                                                }
                                                Example("Basic Card") {
                                                    Card.basic
                                                    CodeBlock("Basic Card - Source Code") {
                                                        #"""
                                                            Card(content: Text("Hello"))
                                                        """#
                                                    }
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

    func testShowcasableWithAutoDiscoveredNestedExamples() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable
                struct Button: View {
                    var body: some View { Text("Button") }
                    
                    struct Examples {
                        @ShowcaseExample(title: "Primary")
                        static var primary: Button { Button() }
                        
                        @ShowcaseExample(title: "Secondary")
                        static var secondary: Button { Button() }
                    }
                }
                """,
                expandedSource: ##"""
                struct Button: View {
                    var body: some View { Text("Button") }
                    
                    struct Examples {
                        static var primary: Button { Button() }

                        static var secondary: Button { Button() }
                    }
                }

                extension Button: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("Button") {
                            CodeBlock("Type Relationships") {
                                """
                                struct Button: View
                                """
                            }
                                    ExampleGroup("Examples") {
                                                Example("Primary") {
                                                    Button.primary
                                                    CodeBlock("Primary - Source Code") {
                                                        #"""
                                                            Button()
                                                        """#
                                                    }
                                                }
                                                Example("Secondary") {
                                                    Button.secondary
                                                    CodeBlock("Secondary - Source Code") {
                                                        #"""
                                                            Button()
                                                        """#
                                                    }
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

    func testShowcasableWithMultipleExternalExampleTypes() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable(examples: [BasicExamples.self, AdvancedExamples.self])
                struct Component: View {
                    var body: some View { Text("Component") }
                    
                    struct BasicExamples {
                        @ShowcaseExample(title: "Simple")
                        static var simple: Component { Component() }
                    }
                    
                    struct AdvancedExamples {
                        @ShowcaseExample(title: "Complex")
                        static var complex: Component { Component() }
                    }
                }
                """,
                expandedSource: ##"""
                struct Component: View {
                    var body: some View { Text("Component") }
                    
                    struct BasicExamples {
                        static var simple: Component { Component() }
                    }
                    
                    struct AdvancedExamples {
                        static var complex: Component { Component() }
                    }
                }

                extension Component: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("Component") {
                            CodeBlock("Type Relationships") {
                                """
                                struct Component: View
                                """
                            }
                                    ExampleGroup("Examples") {
                                                Example("Simple") {
                                                    Component.simple
                                                    CodeBlock("Simple - Source Code") {
                                                        #"""
                                                            Component()
                                                        """#
                                                    }
                                                }
                                                Example("Complex") {
                                                    Component.complex
                                                    CodeBlock("Complex - Source Code") {
                                                        #"""
                                                            Component()
                                                        """#
                                                    }
                                                }
                                                Example("Simple") {
                                                    Component.simple
                                                    CodeBlock("Simple - Source Code") {
                                                        #"""
                                                            Component()
                                                        """#
                                                    }
                                                }
                                                Example("Complex") {
                                                    Component.complex
                                                    CodeBlock("Complex - Source Code") {
                                                        #"""
                                                            Component()
                                                        """#
                                                    }
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
}
