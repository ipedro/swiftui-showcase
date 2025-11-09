// ShowcaseMacros.swift
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

import Showcase

/// Marks a type as showcasable, generating documentation automatically.
///
/// Apply this macro to SwiftUI views or other types to generate a `showcaseTopic`
/// property that contains comprehensive documentation extracted from the code.
///
/// ## Basic Usage
/// ```swift
/// @Showcasable(chapter: "Buttons", icon: "button.horizontal")
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
///
/// - Parameters:
///   - chapter: The chapter name this topic belongs to
///   - icon: Optional SF Symbol name for the topic icon
///   - order: Optional ordering hint within the chapter
///   - autoDiscover: Whether to automatically discover examples and documentation
@attached(extension, conformances: Showcasable, names: named(showcaseTopic), named(showcaseChapter))
public macro Showcasable(
    chapter: String,
    icon: String? = nil,
    order: Int? = nil,
    autoDiscover: Bool = true
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

/// Adds a code block to the showcase documentation.
///
/// Use this macro to include code snippets directly in your showcasable types.
///
/// ## Usage
/// ```swift
/// @Showcasable(chapter: "Utilities")
/// struct NetworkClient {
///     @ShowcaseCodeBlock(title: "Basic Request")
///     static let basicUsage = """
///     let client = NetworkClient()
///     let data = try await client.fetch(url: url)
///     """
/// }
/// ```
///
/// - Parameter title: Optional title for the code block
@attached(peer)
public macro ShowcaseCodeBlock(
    title: String? = nil
) = #externalMacro(module: "ShowcaseMacrosPlugin", type: "ShowcaseCodeBlockMacro")

/// Specifies an icon for the showcase topic.
///
/// Use this macro to override the default icon at the property/method level.
///
/// ## Usage
/// ```swift
/// @Showcasable(chapter: "Components")
/// struct CustomButton {
///     @ShowcaseIcon("star.fill")
///     var body: some View { ... }
/// }
/// ```
///
/// - Parameter name: SF Symbol name
@attached(peer)
public macro ShowcaseIcon(_ name: String) = #externalMacro(module: "ShowcaseMacrosPlugin", type: "ShowcaseIconMacro")

/// Adds a description to the showcase documentation.
///
/// Use this macro to provide additional descriptions beyond doc comments.
///
/// ## Usage
/// ```swift
/// @Showcasable(chapter: "Layouts")
/// struct GridView {
///     @ShowcaseDescription("A responsive grid that adapts to screen size")
///     var body: some View { ... }
/// }
/// ```
///
/// - Parameter text: The description text
@attached(peer)
public macro ShowcaseDescription(_ text: String) = #externalMacro(module: "ShowcaseMacrosPlugin", type: "ShowcaseDescriptionMacro")

/// Adds an external link to the showcase documentation.
///
/// Use this macro to reference external resources, documentation, or examples.
///
/// ## Usage
/// ```swift
/// @Showcasable(chapter: "APIs")
/// struct APIClient {
///     @ShowcaseLink("API Documentation", url: "https://api.example.com/docs")
///     static let documentation = ()
/// }
/// ```
///
/// - Parameters:
///   - title: Link title
///   - url: Target URL as string
@attached(peer)
public macro ShowcaseLink(
    _ title: String,
    url: String
) = #externalMacro(module: "ShowcaseMacrosPlugin", type: "ShowcaseLinkMacro")

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
public protocol Showcasable {
    /// The generated topic containing this type's documentation.
    @MainActor static var showcaseTopic: Topic { get }
    
    /// The chapter this showcasable belongs to.
    static var showcaseChapter: String { get }
}
