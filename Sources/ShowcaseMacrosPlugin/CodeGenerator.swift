// CodeGenerator.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/9/25.
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

/// Generates Showcasable extension code.
enum CodeGenerator {
    static func generateMembers(
        config: TopicConfiguration,
        docs: TopicDocumentation,
        members: TopicMembers
    ) -> (showcaseTopic: DeclSyntax, chapter: DeclSyntax) {
        let content = TopicContentGenerator.generate(
            config: config,
            docs: docs,
            members: members
        )

        let topicInit = if let icon = config.icon {
            "Topic(\"\(config.typeInfo.name)\", icon: Image(systemName: \"\(icon)\"))"
        } else {
            "Topic(\"\(config.typeInfo.name)\")"
        }

        let showcaseTopicDecl = DeclSyntax(stringLiteral: """
        public static var showcaseTopic: Topic {
            \(topicInit) {\(content)}
        }
        """)

        let chapterDecl = DeclSyntax(stringLiteral: """
        public static var showcaseChapter: String { "\(config.chapter)" }
        """)

        return (showcaseTopicDecl, chapterDecl)
    }

    /// Indents multi-line strings for proper embedding in generated code.
    static func indentMultiline(_ text: String, indent: String) -> String {
        let lines = text.components(separatedBy: "\n")
        guard lines.count > 1 else { return text }

        return lines.enumerated().map { index, line in
            index == 0 ? line : indent + line
        }.joined(separator: "\n")
    }
}
