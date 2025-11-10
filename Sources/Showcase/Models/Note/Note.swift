// Note.swift
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

import Foundation

/// A special callout block for highlighting important information.
///
/// Notes are used to draw attention to important details, warnings, deprecations,
/// or other significant information that should stand out from regular text.
///
/// Example usage:
/// ```swift
/// Topic("MyComponent") {
///     Note(.warning) {
///         "This API is deprecated. Use NewAPI instead."
///     }
///
///     Note(.note) {
///         "Remember to call cleanup() when done."
///     }
/// }
/// ```
public struct Note: Equatable, Hashable, Sendable {
    /// The type of note, which affects its visual appearance.
    public let type: NoteType

    /// The content of the note.
    public let content: String

    /// Creates a note with the specified type and content.
    ///
    /// - Parameters:
    ///   - type: The type of note (note, warning, important, etc.)
    ///   - content: The text content of the note
    public init(
        _ type: NoteType = .note,
        content: () -> String
    ) {
        self.type = type
        self.content = content()
    }

    /// The different types of notes with their semantic meanings.
    public enum NoteType: String, Equatable, Hashable, Sendable, CaseIterable {
        /// General informational note
        case note = "Note"

        /// Important information that requires attention
        case important = "Important"

        /// Warning about potential issues or risks
        case warning = "Warning"

        /// Deprecated functionality
        case deprecated = "Deprecated"

        /// Experimental or beta features
        case experimental = "Experimental"

        /// Tips and best practices
        case tip = "Tip"

        /// Returns the display title for the note type
        public var title: String {
            rawValue
        }
    }
}
