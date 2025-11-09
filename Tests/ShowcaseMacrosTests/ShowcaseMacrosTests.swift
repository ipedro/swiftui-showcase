// ShowcaseMacrosTests.swift
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
            expandedSource: """
            struct PrimaryButton: View {
                var body: some View {
                    Button("Primary") {}
                }
            }
            
            extension PrimaryButton: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("PrimaryButton") {
                        CodeBlock(title: "Type Relationships") {
                            \"\"\"
                            struct PrimaryButton: View
                            \"\"\"
                        }
                    }
                }
                public static var showcaseChapter: String {
                    "Buttons"
                }
            }
            """,
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
            expandedSource: """
            struct PrimaryButton: View {
                var body: some View {
                    Button("Primary") {}
                }
            }
            
            extension PrimaryButton: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("PrimaryButton") {
                        Icon(Image(systemName: "button.horizontal"))
                    }
                }
                public static var showcaseChapter: String {
                    "Buttons"
                }
            }
            """,
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
            expandedSource: """
            /// A primary action button.
            struct PrimaryButton: View {
                var body: some View {
                    Button("Primary") {}
                }
            }
            
            extension PrimaryButton: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("PrimaryButton") {
                        Description {
                            \"\"\"
                            A primary action button.
                            \"\"\"
                        }
                    }
                }
                public static var showcaseChapter: String {
                    "Buttons"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
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
            expandedSource: """
            struct PrimaryButton: View {
                static var basic: some View {
                    PrimaryButton()
                }
                
                var body: some View {
                    Button("Primary") {}
                }
            }
            
            extension PrimaryButton: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("PrimaryButton") {
                        Example(title: "Basic") {
                            PrimaryButton.basic
                        }
                    }
                }
                public static var showcaseChapter: String {
                    "Buttons"
                }
            }
            """,
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
            expandedSource: """
            struct ActionButton: View {
                static var withIcon: some View {
                    ActionButton(title: "Submit", icon: "checkmark")
                }
                
                var body: some View {
                    Button("Action") {}
                }
            }

            extension ActionButton: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("ActionButton") {
                        Example(title: "Primary Action") {
                            Description("A primary button with icon")
                            ActionButton.withIcon
                        }
                    }
                }
                public static var showcaseChapter: String {
                    "Buttons"
                }
            }
            """,
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
            @Showcasable(chapter: "Buttons", icon: "button.circle", autoDiscover: false)
            struct ActionButton: View {
                @ShowcaseDescription("A versatile button for actions")
                static let overview = ""
                
                @ShowcaseExample(title: "Basic Usage")
                static var basic: some View {
                    ActionButton(title: "Submit")
                }
                
                @ShowcaseCodeBlock(title: "Integration")
                static let integrationCode = \"\"\"
                ActionButton(title: "Save")
                    .buttonStyle(.borderedProminent)
                \"\"\"
                
                @ShowcaseLink("Design Guidelines", url: "https://example.com/design")
                static let designDoc = ""
                
                @ShowcaseHidden
                private var internalState: Int = 0
                
                var body: some View {
                    Button("Action") {}
                }
            }
            """,
            expandedSource: """
            struct ActionButton: View {
                static let overview = ""

                static var basic: some View {
                    ActionButton(title: "Submit")
                }

                static let integrationCode = \"\"\"
                ActionButton(title: "Save")
                    .buttonStyle(.borderedProminent)
                \"\"\"

                static let designDoc = ""

                private var internalState: Int = 0
                
                var body: some View {
                    Button("Action") {}
                }
            }

            extension ActionButton: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("ActionButton") {
                        Description("A versatile button for actions")
                        Icon(Image(systemName: "button.circle"))
                        CodeBlock(title: "Integration", code: "ActionButton(title: \"Save\")\n    .buttonStyle(.borderedProminent)")
                        Link("Design Guidelines", url: URL(string: "https://example.com/design")!)
                        Example(title: "Basic Usage") {
                            ActionButton.basic
                        }
                    }
                }
                public static var showcaseChapter: String {
                    "Buttons"
                }
            }
            """,
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
            expandedSource: """
            struct PrimaryButton: View {
                var body: some View {
                    Button("Primary") {}
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@Showcasable requires arguments", line: 1, column: 1)
            ],
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
        "ShowcaseCodeBlock": ShowcaseCodeBlockMacro.self,
        "ShowcaseIcon": ShowcaseIconMacro.self,
        "ShowcaseDescription": ShowcaseDescriptionMacro.self,
        "ShowcaseLink": ShowcaseLinkMacro.self,
        "ShowcaseHidden": ShowcaseHiddenMacro.self,
    ]
    #else
    let testMacros: [String: Macro.Type] = [:]
    #endif
    
    func testShowcaseCodeBlockMacro() throws {
        #if canImport(ShowcaseMacrosPlugin)
        assertMacroExpansion(
            """
            @Showcasable(chapter: "Utilities")
            struct NetworkClient {
                @ShowcaseCodeBlock(title: "Basic Request")
                static let basicUsage = \"\"\"
                let client = NetworkClient()
                let data = try await client.fetch(url: url)
                \"\"\"
            }
            """,
            expandedSource: """
            struct NetworkClient {
                static let basicUsage = \"\"\"
                let client = NetworkClient()
                let data = try await client.fetch(url: url)
                \"\"\"
            }

            extension NetworkClient: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("NetworkClient") {
                        CodeBlock(title: "Basic Request", code: "let client = NetworkClient()\\nlet data = try await client.fetch(url: url)")
                    }
                }
                public static var showcaseChapter: String {
                    "Utilities"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testShowcaseIconMacro() throws {
        #if canImport(ShowcaseMacrosPlugin)
        assertMacroExpansion(
            """
            @Showcasable(chapter: "Components")
            struct CustomButton {
                @ShowcaseIcon("star.fill")
                var body: some View {
                    Button("Custom") {}
                }
            }
            """,
            expandedSource: """
            struct CustomButton {
                var body: some View {
                    Button("Custom") {}
                }
            }
            
            extension CustomButton: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("CustomButton") {
                    }
                }
                public static var showcaseChapter: String {
                    "Components"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testShowcaseDescriptionMacro() throws {
        #if canImport(ShowcaseMacrosPlugin)
        assertMacroExpansion(
            """
            @Showcasable(chapter: "Layouts")
            struct GridView {
                @ShowcaseDescription("A responsive grid that adapts to screen size")
                var body: some View {
                    Grid {}
                }
            }
            """,
            expandedSource: """
            struct GridView {
                var body: some View {
                    Grid {}
                }
            }
            
            extension GridView: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("GridView") {
                        Description("A responsive grid that adapts to screen size")
                    }
                }
                public static var showcaseChapter: String {
                    "Layouts"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testShowcaseLinkMacro() throws {
        #if canImport(ShowcaseMacrosPlugin)
        assertMacroExpansion(
            """
            @Showcasable(chapter: "APIs")
            struct APIClient {
                @ShowcaseLink("API Documentation", url: "https://api.example.com/docs")
                static let documentation = ()
            }
            """,
            expandedSource: """
            struct APIClient {
                static let documentation = ()
            }
            
            extension APIClient: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("APIClient") {
                        Link("API Documentation", url: URL(string: "https://api.example.com/docs")!)
                    }
                }
                public static var showcaseChapter: String {
                    "APIs"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
    
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
            expandedSource: """
            struct User {
                var name: String

                private var internalCache: [String: Any]
            }

            extension User: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("User") {
                        CodeBlock(title: "Properties") {
                            \"\"\"
                            var name: String

                            \"\"\"
                        }
                    }
                }
                public static var showcaseChapter: String {
                    "Models"
                }
            }
            """,
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
            expandedSource: """
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
                    return "\\(name) (\\(id))"
                }
            }

            extension DocumentedUser: Showcasable {
                @MainActor public static var showcaseTopic: Topic {
                    Topic("DocumentedUser") {
                        Description {
                            \"\"\"
                            A user model with full documentation
                            \"\"\"
                        }
                        CodeBlock(title: "Initializers") {
                            \"\"\"
                            /// Creates a new user with the given credentials
                            init(id: String, name: String)

                            \"\"\"
                        }
                        CodeBlock(title: "Methods") {
                            \"\"\"
                            /// Validates the user's name
                            /// - Returns: true if the name is valid
                            func validateName() -> Bool

                            /// Gets the user's display string
                            func displayString() -> String

                            \"\"\"
                        }
                        CodeBlock(title: "Properties") {
                            \"\"\"
                            /// The user's unique identifier
                            var id: String

                            /// The user's display name
                            var name: String

                            \"\"\"
                        }
                    }
                }
                public static var showcaseChapter: String {
                    "Models"
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("Macros are only supported when running tests for the host platform")
        #endif
    }
}
