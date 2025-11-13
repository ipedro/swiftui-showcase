// CodeBlockWhitespaceTests.swift
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

import SwiftSyntaxMacrosTestSupport
import XCTest

/// Tests for code block whitespace generation issues
/// These tests ensure that generated code blocks don't have extra blank lines or incorrect formatting
final class CodeBlockWhitespaceTests: ShowcaseMacrosTestsBase {
    // MARK: - Generic Types with Initializers

    func testGenericTypeWithViewBuilderParameter() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// A card component with customizable content
                ///
                /// > The card takes a generic content.
                @Showcasable
                struct DSCard<Content: View>: View {
                    let title: String?
                    /// A view content to display.
                    let content: Content
                    
                    init(title: String? = nil, @ViewBuilder content: () -> Content) {
                        self.title = title
                        self.content = content()
                    }
                    
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                /// A card component with customizable content
                ///
                /// > The card takes a generic content.
                struct DSCard<Content: View>: View {
                    let title: String?
                    /// A view content to display.
                    let content: Content
                    
                    init(title: String? = nil, @ViewBuilder content: () -> Content) {
                        self.title = title
                        self.content = content()
                    }
                    
                    var body: some View {
                        EmptyView()
                    }
                }

                extension DSCard: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("DSCard") {
                            CodeBlock("Type Relationships") {
                                """
                                struct DSCard<Content: View>: View
                                """
                            }
                            Description {
                                """
                                A card component with customizable content
                                """
                            }
                            Note {
                                """
                                The card takes a generic content.
                                """
                            }
                            Topic("init(title:content:)") {
                                CodeBlock("Declaration") {
                                    """
                                    init(title: String?, content: () -> Content)
                                    """
                                }
                            }
                            Topic("title") {
                                CodeBlock("Declaration") {
                                    """
                                    var title: String?
                                    """
                                }
                            }
                            Topic("content") {
                                Description {
                                    """
                                    A view content to display.
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    var content: Content
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

    // MARK: - Torture Tests

    func testMultipleGenericConstraints() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// A complex container with multiple generic constraints
                @Showcasable
                struct Container<Header: View, Content: View, Footer: View>: View {
                    init(
                        @ViewBuilder header: () -> Header,
                        @ViewBuilder content: () -> Content,
                        @ViewBuilder footer: () -> Footer
                    ) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                /// A complex container with multiple generic constraints
                struct Container<Header: View, Content: View, Footer: View>: View {
                    init(
                        @ViewBuilder header: () -> Header,
                        @ViewBuilder content: () -> Content,
                        @ViewBuilder footer: () -> Footer
                    ) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }

                extension Container: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("Container") {
                            CodeBlock("Type Relationships") {
                                """
                                struct Container<Header: View, Content: View, Footer: View>: View
                                """
                            }
                            Description {
                                """
                                A complex container with multiple generic constraints
                                """
                            }
                            Topic("init(header:content:footer:)") {
                                CodeBlock("Declaration") {
                                    """
                                    init(header: () -> Header, content: () -> Content, footer: () -> Footer)
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

    func testMultilineInitializerWithAttributes() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable
                struct ComplexView: View {
                    /// Creates a complex view with many parameters
                    init(
                        title: String,
                        subtitle: String?,
                        @ViewBuilder content: () -> some View,
                        onTap: @escaping () -> Void,
                        isEnabled: Bool = true
                    ) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                struct ComplexView: View {
                    /// Creates a complex view with many parameters
                    init(
                        title: String,
                        subtitle: String?,
                        @ViewBuilder content: () -> some View,
                        onTap: @escaping () -> Void,
                        isEnabled: Bool = true
                    ) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }

                extension ComplexView: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("ComplexView") {
                            CodeBlock("Type Relationships") {
                                """
                                struct ComplexView: View
                                """
                            }
                            Topic("init(title:subtitle:content:onTap:isEnabled:)") {
                                Description {
                                    """
                                    Creates a complex view with many parameters
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    init(title: String, subtitle: String?, content: () -> some View, onTap: @escaping () -> Void, isEnabled: Bool)
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

    func testGenericWithWhereClause() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// A wrapper that only works with identifiable items
                @Showcasable
                struct ItemList<Item: Identifiable>: View where Item.ID == UUID {
                    init(items: [Item]) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                /// A wrapper that only works with identifiable items
                struct ItemList<Item: Identifiable>: View where Item.ID == UUID {
                    init(items: [Item]) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }

                extension ItemList: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("ItemList") {
                            CodeBlock("Type Relationships") {
                                """
                                struct ItemList<Item: Identifiable>: View where Item.ID == UUID
                                """
                            }
                            Description {
                                """
                                A wrapper that only works with identifiable items
                                """
                            }
                            Topic("init(items:)") {
                                CodeBlock("Declaration") {
                                    """
                                    init(items: [Item])
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

    func testMultipleInitializersWithDocComments() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable
                struct Card: View {
                    /// Creates a card with title and content
                    init(title: String, @ViewBuilder content: () -> some View) {}
                    
                    /// Creates a card with only content
                    init(@ViewBuilder content: () -> some View) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                struct Card: View {
                    /// Creates a card with title and content
                    init(title: String, @ViewBuilder content: () -> some View) {}
                    
                    /// Creates a card with only content
                    init(@ViewBuilder content: () -> some View) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }

                extension Card: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("Card") {
                            CodeBlock("Type Relationships") {
                                """
                                struct Card: View
                                """
                            }
                            Topic("init(title:content:)") {
                                Description {
                                    """
                                    Creates a card with title and content
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    init(title: String, content: () -> some View)
                                    """
                                }
                            }
                            Topic("init(content:)") {
                                Description {
                                    """
                                    Creates a card with only content
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    init(content: () -> some View)
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

    func testComplexGenericWithMultipleProtocols() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// A reusable component that handles any hashable and codable data
                @Showcasable
                struct DataView<T: Hashable & Codable>: View {
                    /// Initializes with data
                    init(data: T) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                /// A reusable component that handles any hashable and codable data
                struct DataView<T: Hashable & Codable>: View {
                    /// Initializes with data
                    init(data: T) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }

                extension DataView: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("DataView") {
                            CodeBlock("Type Relationships") {
                                """
                                struct DataView<T: Hashable & Codable>: View
                                """
                            }
                            Description {
                                """
                                A reusable component that handles any hashable and codable data
                                """
                            }
                            Topic("init(data:)") {
                                Description {
                                    """
                                    Initializes with data
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    init(data: T)
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

    func testNestedGenericsWithClosures() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable
                struct ListView<Item, Cell: View>: View {
                    init(
                        items: [Item],
                        @ViewBuilder cell: @escaping (Item) -> Cell
                    ) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                struct ListView<Item, Cell: View>: View {
                    init(
                        items: [Item],
                        @ViewBuilder cell: @escaping (Item) -> Cell
                    ) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }

                extension ListView: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("ListView") {
                            CodeBlock("Type Relationships") {
                                """
                                struct ListView<Item, Cell: View>: View
                                """
                            }
                            Topic("init(items:cell:)") {
                                CodeBlock("Declaration") {
                                    """
                                    init(items: [Item], cell: @escaping (Item) -> Cell)
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

    func testTortureTestAllFeaturesCombined() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// The most complex view ever created
                ///
                /// This view combines:
                /// - Multiple generic parameters
                /// - Complex constraints
                /// - Where clauses
                /// - Multiple initializers
                /// - ViewBuilder closures
                /// - Escaping closures
                ///
                /// > Note: This is intentionally complex to test the macro
                @Showcasable
                struct UltimateView<
                    Header: View,
                    Content: View,
                    Footer: View,
                    Data: Hashable & Codable
                >: View where Data: Identifiable {
                    /// Primary initializer with all parameters
                    init(
                        data: Data,
                        @ViewBuilder header: @escaping (Data) -> Header,
                        @ViewBuilder content: @escaping (Data) -> Content,
                        @ViewBuilder footer: @escaping (Data) -> Footer,
                        onTap: @escaping (Data) -> Void = { _ in }
                    ) {}
                    
                    /// Simplified initializer
                    init(
                        data: Data,
                        @ViewBuilder content: @escaping (Data) -> Content
                    ) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }
                """,
                expandedSource: #"""
                /// The most complex view ever created
                ///
                /// This view combines:
                /// - Multiple generic parameters
                /// - Complex constraints
                /// - Where clauses
                /// - Multiple initializers
                /// - ViewBuilder closures
                /// - Escaping closures
                ///
                /// > Note: This is intentionally complex to test the macro
                struct UltimateView<
                    Header: View,
                    Content: View,
                    Footer: View,
                    Data: Hashable & Codable
                >: View where Data: Identifiable {
                    /// Primary initializer with all parameters
                    init(
                        data: Data,
                        @ViewBuilder header: @escaping (Data) -> Header,
                        @ViewBuilder content: @escaping (Data) -> Content,
                        @ViewBuilder footer: @escaping (Data) -> Footer,
                        onTap: @escaping (Data) -> Void = { _ in }
                    ) {}
                    
                    /// Simplified initializer
                    init(
                        data: Data,
                        @ViewBuilder content: @escaping (Data) -> Content
                    ) {}
                    
                    var body: some View {
                        EmptyView()
                    }
                }

                extension UltimateView: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("UltimateView") {
                            CodeBlock("Type Relationships") {
                                """
                                struct UltimateView<
                                    Header: View,
                                    Content: View,
                                    Footer: View,
                                    Data: Hashable & Codable
                                >: View where Data: Identifiable
                                """
                            }
                            Description {
                                """
                                The most complex view ever created

                                This view combines:
                                - Multiple generic parameters
                                - Complex constraints
                                - Where clauses
                                - Multiple initializers
                                - ViewBuilder closures
                                - Escaping closures
                                """
                            }
                            Note {
                                """
                                Note: This is intentionally complex to test the macro
                                """
                            }
                            Topic("init(data:header:content:footer:onTap:)") {
                                Description {
                                    """
                                    Primary initializer with all parameters
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    init(data: Data, header: @escaping (Data) -> Header, content: @escaping (Data) -> Content, footer: @escaping (Data) -> Footer, onTap: @escaping (Data) -> Void)
                                    """
                                }
                            }
                            Topic("init(data:content:)") {
                                Description {
                                    """
                                    Simplified initializer
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    init(data: Data, content: @escaping (Data) -> Content)
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
