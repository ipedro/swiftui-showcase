// TopicContentGenerator.swift
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

/// Generates topic content from configuration and documentation.
enum TopicContentGenerator {
    private static let singleExampleCodeIndentCount = 20
    private static let exampleGroupCodeIndentCount = 28
    static func generate(
        config: TopicConfiguration,
        docs: TopicDocumentation,
        members: TopicMembers
    ) -> String {
        var topicContent: [String] = []

        // Add type relationships first if enabled
        if let relationships = generateTypeRelationships(config: config) {
            topicContent.append(relationships)
        }

        // Add descriptions
        topicContent.append(contentsOf: generateDescriptions(docs: docs))

        // Add notes
        topicContent.append(contentsOf: generateNotes(docs: docs))

        // Add API reference if members exist
        if let apiReference = generateAPIReference(members: members) {
            topicContent.append(apiReference)
        }

        // Add usage examples
        topicContent.append(contentsOf: generateUsageExamples(docs: docs))

        // Add code blocks
        topicContent.append(contentsOf: generateCodeBlocks(docs: docs))

        // Add links
        topicContent.append(contentsOf: generateLinks(docs: docs))

        // Add examples
        topicContent.append(contentsOf: generateExamples(docs: docs, typeName: config.typeInfo.name))

        return topicContent.isEmpty ? " " : "\n\(topicContent.joined(separator: "\n"))\n"
    }

    // MARK: - Description Generation

    private static func generateDescriptions(docs: TopicDocumentation) -> [String] {
        var content: [String] = []

        // Handle interleaved content parts (text and code blocks in original order)
        var codeBlockIndex = 1
        let totalCodeBlocks = docs.documentation.contentParts.filter {
            if case .codeBlock = $0 { return true }
            return false
        }.count

        for part in docs.documentation.contentParts {
            switch part {
            case let .text(text):
                // Skip empty text
                guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }

                // Multi-line text needs indentation for proper formatting in multi-line string literals
                // In Swift multi-line strings: """ first line has no indent requirement,
                // but subsequent lines must have at least as much indent as the closing """
                let lines = text.components(separatedBy: .newlines)
                let formattedText: String
                if lines.count == 1 {
                    // Single line - no extra indentation needed
                    formattedText = text
                } else {
                    // Multi-line - first line no indent, subsequent non-empty lines get 4 spaces
                    // Empty lines stay empty (no trailing spaces)
                    formattedText = lines.enumerated().map { index, line in
                        if index == 0 {
                            return line
                        } else if line.isEmpty {
                            return "" // Blank lines stay blank, no trailing spaces
                        } else {
                            return "    \(line)" // Add 4 spaces to non-blank lines
                        }
                    }.joined(separator: "\n")
                }

                content.append("""
                Description {
                    \"\"\"
                    \(formattedText)
                    \"\"\"
                }
                """)

            case let .codeBlock(code):
                let title = totalCodeBlocks == 1 ? "Example" : "Example \(codeBlockIndex)"
                content.append(generateCodeBlock(title: title, code: code))
                codeBlockIndex += 1
            }
        }

        // Add any additional descriptions from @ShowcaseDescription attributes
        for description in docs.descriptions {
            content.append("""
            Description {
                \"\"\"
                \(description)
                \"\"\"
            }
            """)
        }

        return content
    }

    private static func generateCodeBlock(title: String, code: String) -> String {
        // Swift multi-line string literals require all content lines to have at least
        // as much indentation as the closing """. Since closing """ is at 4 spaces,
        // we need to add 4 spaces to every line while preserving relative indentation.
        let indentedCode = code.components(separatedBy: .newlines)
            .map { "    \($0)" } // Add 4 spaces to preserve relative indentation
            .joined(separator: "\n")

        return "CodeBlock(\"\(title)\") {\n    \"\"\"\n\(indentedCode)\n    \"\"\"\n}"
    }

    // MARK: - Notes

    private static func generateNotes(docs: TopicDocumentation) -> [String] {
        docs.documentation.notes.map { note in
            """
            Note {
                \"\"\"
                \(note)
                \"\"\"
            }
            """
        }
    }

    // MARK: - Type Relationships

    private static func generateTypeRelationships(config: TopicConfiguration) -> String? {
        guard config.autoDiscover else { return nil }
        guard !config.typeInfo.inheritedTypes.isEmpty || !config.typeInfo.genericConstraints.isEmpty else {
            return nil
        }

        return TypeRelationshipsGenerator.generate(typeInfo: config.typeInfo)
    }

    // MARK: - API Reference

    private static func generateAPIReference(members: TopicMembers) -> String? {
        guard !members.initializers.isEmpty || !members.methods.isEmpty || !members.properties.isEmpty else {
            return nil
        }

        return APIReferenceGenerator.generate(members: members)
    }

    // MARK: - Usage Examples

    private static func generateUsageExamples(docs: TopicDocumentation) -> [String] {
        docs.documentation.usageExamples.enumerated().map { index, usage in
            """
            CodeBlock("Usage Example \(index + 1)") {
                \"\"\"
                \(usage)
                \"\"\"
            }
            """
        }
    }

    // MARK: - Code Blocks

    private static func generateCodeBlocks(docs: TopicDocumentation) -> [String] {
        docs.codeBlocks.map { codeBlock in
            // Use triple-quoted strings to avoid escape sequence issues
            let indentedCode = codeBlock.code.components(separatedBy: .newlines)
                .map { "    \($0)" }
                .joined(separator: "\n")

            return """
            CodeBlock("\(codeBlock.title)") {
                \"\"\"
            \(indentedCode)
                \"\"\"
            }
            """
        }
    }

    // MARK: - Links

    private static func generateLinks(docs: TopicDocumentation) -> [String] {
        docs.links.map { link in
            "Link(\"\(link.title)\", url: URL(string: \"\(link.url)\")!)"
        }
    }

    // MARK: - Examples

    private static func generateExamples(docs: TopicDocumentation, typeName: String) -> [String] {
        guard !docs.examples.isEmpty else { return [] }

        // If we have 2+ examples, group them in an ExampleGroup for tabbed navigation
        // Provides consistent UI and better discoverability even with just two examples
        if docs.examples.count >= 2 {
            return [generateExampleGroup(docs: docs, typeName: typeName)]
        }

        // Otherwise, generate individual examples
        var content: [String] = []
        for example in docs.examples {
            content.append(generateSingleExample(example: example, typeName: typeName))
        }
        return content
    }

    private static func generateExampleGroup(docs: TopicDocumentation, typeName: String) -> String {
        var lines: [String] = []

        lines.append("        ExampleGroup(\"Examples\") {")
        for example in docs.examples {
            let exampleTitle = "\"\(example.title)\""
            lines.append("                    Example(\(exampleTitle)) {")

            // Add description if present
            if let description = example.description {
                lines.append("                        Description {")
                lines.append("                            \"\"\"")
                lines.append("                            \(description)")
                lines.append("                            \"\"\"")
                lines.append("                        }")
            }

            lines.append("                        \(typeName).\(example.name)")
            let codeBlockLines = codeBlockLines(for: example, codeIndentCount: exampleGroupCodeIndentCount)
            lines.append(contentsOf: codeBlockLines)
            lines.append("                    }")
        }
        lines.append("        }")

        return lines.joined(separator: "\n")
    }

    private static func generateSingleExample(example: ExampleInfo, typeName: String) -> String {
        let exampleTitle = "\"\(example.title)\""
        var lines: [String] = []
        lines.append("            Example(\(exampleTitle)) {")

        // Add description if present
        if let description = example.description {
            lines.append("                Description {")
            lines.append("                    \"\"\"")
            lines.append("                    \(description)")
            lines.append("                    \"\"\"")
            lines.append("                }")
        }

        lines.append("                \(typeName).\(example.name)")
        let codeBlockLines = codeBlockLines(for: example, codeIndentCount: singleExampleCodeIndentCount)
        lines.append(contentsOf: codeBlockLines)
        lines.append("            }")
        return lines.joined(separator: "\n")
    }

    private static func codeBlockLines(for example: ExampleInfo, codeIndentCount: Int) -> [String] {
        guard example.showCode, let sourceCode = example.sourceCode else { return [] }

        let codeTitle = "\(example.title) - Source Code"
        let blockIndentCount = max(codeIndentCount - 4, 0)
        let blockIndent = String(repeating: " ", count: blockIndentCount)
        let stringLiteralIndent = String(repeating: " ", count: blockIndentCount + 4) // Opening/closing quotes
        let contentIndent = String(repeating: " ", count: blockIndentCount + 8) // Content needs more indent

        // Build the entire CodeBlock as a single multi-line string
        var codeBlock = ""
        codeBlock += "\(blockIndent)CodeBlock(\"\(codeTitle)\") {\n"
        codeBlock += "\(stringLiteralIndent)#\"\"\"\n" // Use raw string literal (#"""...""#)

        // Add each line of source code (raw strings handle backslashes literally)
        for line in sourceCode.components(separatedBy: "\n") {
            codeBlock += "\(contentIndent)\(line)\n"
        }

        codeBlock += "\(stringLiteralIndent)\"\"\"#\n"
        codeBlock += "\(blockIndent)}"

        return [codeBlock]
    }
}
