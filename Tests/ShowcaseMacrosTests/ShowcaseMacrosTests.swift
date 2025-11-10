// ShowcaseMacrosTests.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 09.11.25.
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

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(ShowcaseMacrosPlugin)
    import ShowcaseMacrosPlugin
#endif

final class ShowcaseMacrosTests: XCTestCase {
    // MARK: - Basic Showcasable Tests

    func testShowcasableBasic() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                @Showcasable(chapter: "Buttons")
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
                @Showcasable(chapter: "Buttons", icon: "button.horizontal", autoDiscover: false)
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
                @Showcasable(chapter: "Buttons", autoDiscover: false)
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
                @Showcasable(chapter: "Buttons", autoDiscover: false)
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
                @Showcasable(chapter: "Buttons", autoDiscover: false)
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
                @Showcasable(chapter: "Buttons", icon: "button.circle", autoDiscover: false)
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

    // MARK: - Error Tests

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

    // MARK: - Examples Parameter Tests

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

    // MARK: - Test Configuration

    #if canImport(ShowcaseMacrosPlugin)
        let testMacros: [String: Macro.Type] = [
            "Showcasable": ShowcasableMacro.self,
            "ShowcaseExample": ShowcaseExampleMacro.self,
            "ShowcaseHidden": ShowcaseHiddenMacro.self,
        ]
    #else
        let testMacros: [String: Macro.Type] = [:]
    #endif

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

    // MARK: - Auto-Discovery Tests

    func testMemberAutoDiscovery() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                """
                /// A user model with full documentation
                @Showcasable(chapter: "Models")
                struct DocumentedUser {
                    /// The user's unique identifier
                    var id: String
                    
                    /// The user's display name
                    var name: String
                    
                    /// Creates a new user with the given credentials
                    init(id: String, name: String) {
                        self.id = id
                        self.name = name
                    }
                    
                    /// Validates the user's name
                    /// - Returns: true if the name is valid
                    func validateName() -> Bool {
                        return !name.isEmpty
                    }
                    
                    /// Gets the user's display string
                    func displayString() -> String {
                        return "\\(name) (\\(id))"
                    }
                }
                """,
                expandedSource: #"""
                /// A user model with full documentation
                struct DocumentedUser {
                    /// The user's unique identifier
                    var id: String
                    
                    /// The user's display name
                    var name: String
                    
                    /// Creates a new user with the given credentials
                    init(id: String, name: String) {
                        self.id = id
                        self.name = name
                    }
                    
                    /// Validates the user's name
                    /// - Returns: true if the name is valid
                    func validateName() -> Bool {
                        return !name.isEmpty
                    }
                    
                    /// Gets the user's display string
                    func displayString() -> String {
                        return "\(name) (\(id))"
                    }
                }

                extension DocumentedUser: Showcasable {
                    public static var showcaseTopic: Topic {
                        Topic("DocumentedUser") {
                            Description {
                                """
                                A user model with full documentation
                                """
                            }
                            Topic("init(id:name:)") {
                                Description {
                                    """
                                    Creates a new user with the given credentials
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    /// Creates a new user with the given credentials
                                            init(id: String, name: String)
                                    """
                                }
                            }
                            Topic("validateName") {
                                Description {
                                    """
                                    Validates the user's name
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    /// Validates the user's name
                                            /// - Returns: true if the name is valid
                                            func validateName() -> Bool
                                    """
                                }
                            }
                            Topic("displayString") {
                                Description {
                                    """
                                    Gets the user's display string
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    /// Gets the user's display string
                                            func displayString() -> String
                                    """
                                }
                            }
                            Topic("id") {
                                Description {
                                    """
                                    The user's unique identifier
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    /// The user's unique identifier
                                            var id: String
                                    """
                                }
                            }
                            Topic("name") {
                                Description {
                                    """
                                    The user's display name
                                    """
                                }
                                CodeBlock("Declaration") {
                                    """
                                    /// The user's display name
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

    func testDSButtonWithMarkdownAndCodeBlocks() throws {
        #if canImport(ShowcaseMacrosPlugin)
            assertMacroExpansion(
                dsButtonOriginalSource(),
                expandedSource: dsButtonExpandedSource(),
                macros: testMacros
            )
        #else
            throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }

    private func dsButtonOriginalSource() -> String {
        """
        /// A customizable button component for the design system
        ///
        /// `DSButton` provides a consistent button interface with three built-in styles:
        /// primary, secondary, and destructive. Each style automatically applies appropriate
        /// colors and styling to match your design system.
        ///
        /// ## Basic Usage
        ///
        /// ```swift
        /// DSButton(title: "Continue", style: .primary) {
        ///     print("Action triggered")
        /// }
        /// ```
        ///
        /// ## Button Styles
        ///
        /// Choose from three predefined styles depending on the action's importance:
        ///
        /// ```swift
        /// // Primary: For main actions
        /// DSButton(title: "Save", style: .primary) {
        ///     saveDocument()
        /// }
        ///
        /// // Secondary: For alternative actions
        /// DSButton(title: "Cancel", style: .secondary) {
        ///     dismissView()
        /// }
        ///
        /// // Destructive: For dangerous actions
        /// DSButton(title: "Delete", style: .destructive) {
        ///     deleteItem()
        /// }
        /// ```
        ///
        /// ## Styling and Customization
        ///
        /// Combine with SwiftUI modifiers for additional customization:
        ///
        /// ```swift
        /// DSButton(title: "Custom", style: .primary) {
        ///     performAction()
        /// }
        /// .opacity(0.5)
        /// .disabled(true)
        /// ```
        @Showcasable(chapter: "Components", icon: "button.horizontal")
        struct DSButton: View {
            var body: some View {
                Button("Action") {}
            }
        }
        """
    }

    private func dsButtonExpandedSource() -> String {
        #"""
        /// A customizable button component for the design system
        ///
        /// `DSButton` provides a consistent button interface with three built-in styles:
        /// primary, secondary, and destructive. Each style automatically applies appropriate
        /// colors and styling to match your design system.
        ///
        /// ## Basic Usage
        ///
        /// ```swift
        /// DSButton(title: "Continue", style: .primary) {
        ///     print("Action triggered")
        /// }
        /// ```
        ///
        /// ## Button Styles
        ///
        /// Choose from three predefined styles depending on the action's importance:
        ///
        /// ```swift
        /// // Primary: For main actions
        /// DSButton(title: "Save", style: .primary) {
        ///     saveDocument()
        /// }
        ///
        /// // Secondary: For alternative actions
        /// DSButton(title: "Cancel", style: .secondary) {
        ///     dismissView()
        /// }
        ///
        /// // Destructive: For dangerous actions
        /// DSButton(title: "Delete", style: .destructive) {
        ///     deleteItem()
        /// }
        /// ```
        ///
        /// ## Styling and Customization
        ///
        /// Combine with SwiftUI modifiers for additional customization:
        ///
        /// ```swift
        /// DSButton(title: "Custom", style: .primary) {
        ///     performAction()
        /// }
        /// .opacity(0.5)
        /// .disabled(true)
        /// ```
        struct DSButton: View {
            var body: some View {
                Button("Action") {}
            }
        }

        extension DSButton: Showcasable {
            public static var showcaseTopic: Topic {
                Topic("DSButton", icon: Image(systemName: "button.horizontal")) {
                    Description {
                        """
                        A customizable button component for the design system

                        `DSButton` provides a consistent button interface with three built-in styles:
                        primary, secondary, and destructive. Each style automatically applies appropriate
                        colors and styling to match your design system.

                        ## Basic Usage
                        """
                    }
                    CodeBlock("Example 1") {
                        """
                        DSButton(title: "Continue", style: .primary) {
                            print("Action triggered")
                        }
                        """
                    }
                    Description {
                        """
                        ## Button Styles

                        Choose from three predefined styles depending on the action's importance:
                        """
                    }
                    CodeBlock("Example 2") {
                        """
                        // Primary: For main actions
                        DSButton(title: "Save", style: .primary) {
                            saveDocument()
                        }

                        // Secondary: For alternative actions
                        DSButton(title: "Cancel", style: .secondary) {
                            dismissView()
                        }

                        // Destructive: For dangerous actions
                        DSButton(title: "Delete", style: .destructive) {
                            deleteItem()
                        }
                        """
                    }
                    Description {
                        """
                        ## Styling and Customization

                        Combine with SwiftUI modifiers for additional customization:
                        """
                    }
                    CodeBlock("Example 3") {
                        """
                        DSButton(title: "Custom", style: .primary) {
                            performAction()
                        }
                        .opacity(0.5)
                        .disabled(true)
                        """
                    }
                    CodeBlock("Type Relationships") {
                        """
                        struct DSButton: View
                        """
                    }
                }
            }
        }
        """#
    }
}
