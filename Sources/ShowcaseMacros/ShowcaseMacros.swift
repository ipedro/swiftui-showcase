// ShowcaseMacros.swift
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

@_exported import Showcase

/// Marks a type as showcasable, generating documentation automatically.
///
/// Apply this macro to SwiftUI views or other types to generate a `showcaseTopic`
/// property that contains comprehensive documentation extracted from the code.
///
/// ## Basic Usage
/// ```swift
/// @Showcasable(icon: "button.horizontal")
/// struct PrimaryButton: View {
///     var body: some View {
///         Button("Primary") {}
///     }
/// }
///
/// // Use in documentation:
/// Document("Design System") {
///     Chapter("Buttons") {
///         PrimaryButton.showcaseTopic
///     }
/// }
/// ```
///
/// ## Auto-Discovery
/// When `autoDiscover` is `true` (default), the macro automatically includes:
/// - Doc comments as descriptions
/// - `@ShowcaseExample` functions as interactive examples
/// - `@available` attributes as platform requirements
/// - Usage sections from doc comments as code blocks
/// - Examples in nested types (automatically discovered)
///
/// ## External Examples
/// The `examples` parameter is for external example types that cannot be auto-discovered.
/// Due to Swift macro limitations, these must still be declared in the same file:
/// ```swift
/// @Showcasable(examples: [CardExamples.self])
/// struct Card<Content: View>: View {
///     var body: some View { content }
/// }
///
/// // External example container (same file, different scope)
/// struct CardExamples {
///     @ShowcaseExample(title: "Basic")
///     static var basic: some View { Card { Text("Content") } }
/// }
/// ```
///
/// For nested types, examples are automatically discovered:
/// ```swift
/// @Showcasable
/// struct Button: View {
///     struct Examples {  // Auto-discovered, no need to specify
///         @ShowcaseExample(title: "Primary")
///         static var primary: some View { Button("Primary") }
///     }
/// }
/// ```
///
/// - Parameters:
///   - icon: Optional SF Symbol name for the topic icon
///   - order: Optional ordering hint within chapters
///   - autoDiscover: Whether to automatically discover examples and documentation
///   - examples: External types containing @ShowcaseExample properties (same file only)
@attached(extension, conformances: Showcasable, names: named(showcaseTopic))
public macro Showcasable(
    icon: String? = nil,
    order: Int? = nil,
    autoDiscover: Bool = true,
    examples: [Any.Type] = []
) = #externalMacro(module: "ShowcaseMacrosPlugin", type: "ShowcasableMacro")

/// Marks a static property or function as a showcase example.
///
/// Use this macro to mark views that should be included as interactive
/// examples in the generated documentation.
///
/// ## Usage
/// ```swift
/// @Showcasable(chapter: "Buttons")
/// struct PrimaryButton: View {
///     @ShowcaseExample(title: "Basic Usage")
///     static var basic: some View {
///         PrimaryButton(label: "Tap Me")
///     }
///
///     @ShowcaseExample(title: "Loading State", description: "Shows loading indicator")
///     static var loading: some View {
///         PrimaryButton(label: "Loading...", isLoading: true)
///     }
/// }
/// ```
///
/// - Parameters:
///   - title: Optional title for the example (defaults to property name)
///   - description: Optional description explaining what the example demonstrates
@attached(peer)
public macro ShowcaseExample(
    title: String? = nil,
    description: String? = nil
) = #externalMacro(module: "ShowcaseMacrosPlugin", type: "ShowcaseExampleMacro")

/// Hides a member from showcase documentation.
///
/// Use this macro to exclude specific properties or methods from auto-discovery.
///
/// ## Usage
/// ```swift
/// @Showcasable(chapter: "Models", autoDiscover: true)
/// struct User {
///     var name: String
///
///     @ShowcaseHidden
///     private var internalCache: [String: Any]
/// }
/// ```
@attached(peer)
public macro ShowcaseHidden() = #externalMacro(module: "ShowcaseMacrosPlugin", type: "ShowcaseHiddenMacro")

// MARK: - Protocol

/// A type that can provide showcase documentation.
///
/// This protocol is automatically conformed to by types marked with `@Showcasable`.
/// You typically don't need to conform to this manually.
///
/// Note: This is a re-export from the Showcase module for backwards compatibility.
@_exported import protocol Showcase.Showcasable
