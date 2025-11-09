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
            @Showcasable(chapter: "Buttons", icon: "button.horizontal")
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
            @Showcasable(chapter: "Buttons")
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
            @Showcasable(chapter: "Buttons")
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
                        Example(title: "basic") {
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
        "ShowcaseExample": ShowcaseExampleMacro.self
    ]
    #else
    let testMacros: [String: Macro.Type] = [:]
    #endif
}
