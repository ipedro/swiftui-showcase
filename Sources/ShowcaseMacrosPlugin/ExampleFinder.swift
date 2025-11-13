// ExampleFinder.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/13/25.
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

/// Finds @ShowcaseExample marked members.
enum ExampleFinder {
    /// Finds examples in the given declaration and optionally in specified example types.
    ///
    /// - Parameters:
    ///   - declaration: The declaration to search for examples
    ///   - exampleTypes: Array of type names for external example containers. Nested types
    ///                   are automatically discovered without needing to be specified here.
    ///
    /// - Returns: Array of example information found
    static func findExamples(
        in declaration: some DeclGroupSyntax,
        exampleTypes: [String] = []
    ) -> [ExampleInfo] {
        var examples: [ExampleInfo] = []

        // Find examples in the main declaration
        examples.append(contentsOf: findExamplesInDeclaration(declaration))

        // Auto-discover examples in ALL nested types
        examples.append(contentsOf: findExamplesInNestedTypes(declaration))

        // If explicitly specified example types are provided, find them as nested types
        // (Due to macro limitations, referenced types must be nested within the same declaration)
        for typeName in exampleTypes where !typeName.isEmpty {
            if let nestedType = findNestedType(named: typeName, in: declaration) {
                examples.append(contentsOf: findExamplesInDeclaration(nestedType))
            }
        }

        return examples
    }

    /// Finds examples in all nested types within a declaration.
    private static func findExamplesInNestedTypes(_ declaration: some DeclGroupSyntax) -> [ExampleInfo] {
        var examples: [ExampleInfo] = []

        for member in declaration.memberBlock.members {
            // Check for nested type declarations
            if let structDecl = member.decl.as(StructDeclSyntax.self) {
                examples.append(contentsOf: findExamplesInDeclaration(structDecl))
            } else if let classDecl = member.decl.as(ClassDeclSyntax.self) {
                examples.append(contentsOf: findExamplesInDeclaration(classDecl))
            } else if let enumDecl = member.decl.as(EnumDeclSyntax.self) {
                examples.append(contentsOf: findExamplesInDeclaration(enumDecl))
            } else if let actorDecl = member.decl.as(ActorDeclSyntax.self) {
                examples.append(contentsOf: findExamplesInDeclaration(actorDecl))
            }
        }

        return examples
    }

    /// Finds a nested type by name within a declaration.
    private static func findNestedType(
        named name: String,
        in declaration: some DeclGroupSyntax
    ) -> (any DeclGroupSyntax)? {
        for member in declaration.memberBlock.members {
            // Check for struct, class, enum, or actor declarations
            if let structDecl = member.decl.as(StructDeclSyntax.self),
               structDecl.name.text == name {
                return structDecl
            }
            if let classDecl = member.decl.as(ClassDeclSyntax.self),
               classDecl.name.text == name {
                return classDecl
            }
            if let enumDecl = member.decl.as(EnumDeclSyntax.self),
               enumDecl.name.text == name {
                return enumDecl
            }
            if let actorDecl = member.decl.as(ActorDeclSyntax.self),
               actorDecl.name.text == name {
                return actorDecl
            }
        }
        return nil
    }

    /// Finds examples within a specific declaration.
    private static func findExamplesInDeclaration(_ declaration: some DeclGroupSyntax) -> [ExampleInfo] {
        var examples: [ExampleInfo] = []

        for member in declaration.memberBlock.members {
            // Skip hidden members
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseHidden") {
                continue
            }

            // Check if member has @ShowcaseExample attribute
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseExample"),
               let binding = varDecl.bindings.first,
               let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                // Extract title, description, and showCode from attribute
                let (title, description, showCode) = extractExampleMetadata(from: varDecl)

                // Extract source code from the property body
                let sourceCode = extractSourceCode(from: binding)

                examples.append(ExampleInfo(
                    name: name,
                    title: title ?? name,
                    description: description,
                    sourceCode: sourceCode,
                    showCode: showCode
                ))
            }
        }

        return examples
    }

    static func findCodeBlocks(in declaration: some DeclGroupSyntax) -> [CodeBlockInfo] {
        // Code blocks are no longer supported via @ShowcaseCodeBlock macro
        // Use doc comments with code blocks instead
        []
    }

    static func findLinks(in declaration: some DeclGroupSyntax) -> [LinkInfo] {
        // Links are no longer supported via @ShowcaseLink macro
        // Document links in doc comments instead
        []
    }

    static func findDescriptions(in declaration: some DeclGroupSyntax) -> [String] {
        // Descriptions are no longer supported via @ShowcaseDescription macro
        // Use doc comments on the type instead
        []
    }

    // MARK: - Metadata Extraction

    private static func extractExampleMetadata(
        from varDecl: VariableDeclSyntax
    ) -> (title: String?, description: String?, showCode: Bool) {
        guard let exampleAttr = varDecl.attributes.first(where: { attr in
            attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ShowcaseExample"
        })?.as(AttributeSyntax.self) else {
            return (nil, nil, true)
        }

        guard let arguments = exampleAttr.arguments?.as(LabeledExprListSyntax.self) else {
            return (nil, nil, true)
        }

        var title: String?
        var description: String?
        var showCode = true

        for argument in arguments {
            let label = argument.label?.text

            if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
               let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                let value = segment.content.text

                switch label {
                case "title":
                    title = value
                case "description":
                    description = value
                default:
                    break
                }
            }

            if label == "showCode",
               let boolExpr = argument.expression.as(BooleanLiteralExprSyntax.self) {
                showCode = boolExpr.literal.text == "true"
            }
        }

        return (title, description, showCode)
    }

    // MARK: - Source Code Extraction

    private static func extractSourceCode(from binding: PatternBindingSyntax) -> String? {
        // Try to extract from accessor (computed property getter)
        if let accessorBlock = binding.accessorBlock,
           case let .getter(codeBlockItems) = accessorBlock.accessors {
            return formatSourceCode(codeBlockItems.description)
        }

        // Try to extract from initializer (stored property with initial value)
        if let initializer = binding.initializer {
            return formatSourceCode(initializer.value.description)
        }

        return nil
    }

    private static func formatSourceCode(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)

        // Find minimum indentation (excluding empty lines)
        let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        guard let minIndent = nonEmptyLines.map({ line in
            line.prefix(while: { $0.isWhitespace }).count
        }).min() else {
            return code.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // Remove the common indentation from all lines
        let formatted = lines.map { line in
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { return "" }
            return String(line.dropFirst(min(minIndent, line.count)))
        }.joined(separator: "\n")

        return formatted.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractStringLiteralContent(from stringLiteral: StringLiteralExprSyntax) -> String {
        var content = ""
        for segment in stringLiteral.segments {
            if let stringSegment = segment.as(StringSegmentSyntax.self) {
                content += stringSegment.content.text
            }
        }
        return content
    }
}
