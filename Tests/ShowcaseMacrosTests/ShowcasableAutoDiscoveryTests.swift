// ShowcasableAutoDiscoveryTests.swift
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

/// Tests for @Showcasable macro's auto-discovery functionality
final class ShowcasableAutoDiscoveryTests: ShowcaseMacrosTestsBase {
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
