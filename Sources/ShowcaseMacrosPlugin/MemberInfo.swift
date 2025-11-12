// MemberInfo.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/12/25.
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

struct ExampleInfo {
    let name: String
    let title: String
    let description: String?
    let sourceCode: String?
    let showCode: Bool
}

struct CodeBlockInfo {
    let title: String
    let code: String
}

struct LinkInfo {
    let title: String
    let url: String
}

struct InitializerInfo {
    let signature: String
    let docComment: DocComment
}

struct MethodInfo {
    let name: String
    let signature: String
    let isStatic: Bool
    let docComment: DocComment
}

struct PropertyInfo {
    let name: String
    let type: String
    let isComputed: Bool
    let isStatic: Bool
    let docComment: DocComment
}

/// Represents a content part in documentation - either text or code
enum ContentPart: Equatable {
    case text(String)
    case codeBlock(String)
}

/// Represents a parsed documentation comment with structured sections.
struct DocComment {
    /// The summary (first paragraph)
    let summary: String?

    /// Extended discussion (middle paragraphs before special sections)
    let discussion: String?

    /// Interleaved content parts (text and code blocks in original order)
    let contentParts: [ContentPart]

    /// Parameter descriptions keyed by parameter name
    let parameters: [String: String]

    /// Return value description
    let returns: String?

    /// Information about what this member throws
    let `throws`: String?

    /// Note callouts
    let notes: [String]

    /// Warning callouts
    let warnings: [String]

    /// Important callouts
    let important: [String]

    /// Code blocks extracted from doc comments (e.g., ```swift ... ```)
    /// @deprecated Use contentParts instead for proper interleaving
    var codeBlocks: [String] {
        contentParts.compactMap {
            if case let .codeBlock(code) = $0 { return code }
            return nil
        }
    }
}
