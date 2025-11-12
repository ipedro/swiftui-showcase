// MemberDiscovery.swift
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

import SwiftSyntax

/// Discovers and extracts information about type members for auto-documentation.
enum MemberDiscovery {
    /// Discovers all public initializers in a type.
    static func findInitializers(in declaration: some DeclGroupSyntax) -> [InitializerInfo] {
        var initializers: [InitializerInfo] = []

        for member in declaration.memberBlock.members {
            // Skip hidden members
            if member.hasAttribute(named: "ShowcaseHidden") {
                continue
            }

            guard let initDecl = member.decl.as(InitializerDeclSyntax.self) else {
                continue
            }

            guard isAccessible(initDecl) else {
                continue
            }

            let signature = extractInitializerSignature(from: initDecl)
            let docComment = extractDocComment(from: initDecl)

            initializers.append(InitializerInfo(
                signature: signature,
                docComment: docComment
            ))
        }

        return initializers
    }

    /// Discovers all public methods in a type.
    static func findMethods(in declaration: some DeclGroupSyntax) -> [MethodInfo] {
        var methods: [MethodInfo] = []

        for member in declaration.memberBlock.members {
            // Skip hidden members
            if member.hasAttribute(named: "ShowcaseHidden") {
                continue
            }

            guard let funcDecl = member.decl.as(FunctionDeclSyntax.self) else {
                continue
            }

            guard isAccessible(funcDecl) else {
                continue
            }

            let isStatic = funcDecl.modifiers.contains { modifier in
                modifier.name.text == "static" || modifier.name.text == "class"
            }

            let name = funcDecl.name.text
            let signature = extractMethodSignature(from: funcDecl)
            let docComment = extractDocComment(from: funcDecl)

            methods.append(MethodInfo(
                name: name,
                signature: signature,
                isStatic: isStatic,
                docComment: docComment
            ))
        }

        return methods
    }

    /// Discovers all public properties in a type.
    static func findProperties(in declaration: some DeclGroupSyntax) -> [PropertyInfo] {
        var properties: [PropertyInfo] = []

        for member in declaration.memberBlock.members {
            // Skip hidden members
            if member.hasAttribute(named: "ShowcaseHidden") {
                continue
            }

            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }

            guard shouldIncludeProperty(varDecl) else {
                continue
            }

            let isStatic = varDecl.modifiers.contains { modifier in
                modifier.name.text == "static" || modifier.name.text == "class"
            }

            for binding in varDecl.bindings {
                guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                    continue
                }

                // Skip SwiftUI View's body property
                if name == "body" {
                    continue
                }

                let type = binding.typeAnnotation?.type.description.trimmingCharacters(in: .whitespaces) ?? "Unknown"
                let isComputed = binding.accessorBlock != nil
                let docComment = extractDocComment(from: varDecl)

                properties.append(PropertyInfo(
                    name: name,
                    type: type,
                    isComputed: isComputed,
                    isStatic: isStatic,
                    docComment: docComment
                ))
            }
        }

        return properties
    }

    // MARK: - Access Control

    private static func isAccessible(_ decl: InitializerDeclSyntax) -> Bool {
        let isPublic = decl.modifiers.contains { modifier in
            modifier.name.text == "public" || modifier.name.text == "internal"
        }

        let hasNoAccessModifier = !decl.modifiers.contains { modifier in
            ["public", "internal", "private", "fileprivate"].contains(modifier.name.text)
        }

        return isPublic || hasNoAccessModifier
    }

    private static func isAccessible(_ decl: FunctionDeclSyntax) -> Bool {
        let isPublic = decl.modifiers.contains { modifier in
            modifier.name.text == "public" || modifier.name.text == "internal"
        }

        let hasNoAccessModifier = !decl.modifiers.contains { modifier in
            ["public", "internal", "private", "fileprivate"].contains(modifier.name.text)
        }

        return isPublic || hasNoAccessModifier
    }

    private static func isAccessible(_ decl: VariableDeclSyntax) -> Bool {
        let isPublic = decl.modifiers.contains { modifier in
            modifier.name.text == "public" || modifier.name.text == "internal"
        }

        let hasNoAccessModifier = !decl.modifiers.contains { modifier in
            ["public", "internal", "private", "fileprivate"].contains(modifier.name.text)
        }

        return isPublic || hasNoAccessModifier
    }

    private static func shouldIncludeProperty(_ varDecl: VariableDeclSyntax) -> Bool {
        // Skip showcase-related attributes (they're documentation, not API)
        let showcaseAttributes = [
            "ShowcaseExample",
        ]

        return !showcaseAttributes.contains(where: { varDecl.hasAttribute(named: $0) }) && isAccessible(varDecl)
    }

    // MARK: - Signature Extraction

    private static func extractInitializerSignature(from initDecl: InitializerDeclSyntax) -> String {
        var signature = "init"

        let params = initDecl.signature.parameterClause.parameters
        if params.isEmpty {
            signature += "()"
        } else {
            let paramStrings = params.map { extractParameterString(from: $0) }
            signature += "(" + paramStrings.joined(separator: ", ") + ")"
        }

        return signature
    }

    private static func extractMethodSignature(from funcDecl: FunctionDeclSyntax) -> String {
        var signature = funcDecl.name.text

        let params = funcDecl.signature.parameterClause.parameters
        if params.isEmpty {
            signature += "()"
        } else {
            let paramStrings = params.map { extractParameterString(from: $0) }
            signature += "(" + paramStrings.joined(separator: ", ") + ")"
        }

        if let returnType = funcDecl.signature.returnClause?.type {
            signature += " -> \(returnType.description.trimmingCharacters(in: .whitespaces))"
        }

        return signature
    }

    private static func extractParameterString(from param: FunctionParameterSyntax) -> String {
        let firstName = param.firstName.text
        let secondName = param.secondName?.text
        let type = param.type.description.trimmingCharacters(in: .whitespaces)

        if let secondName = secondName {
            return "\(firstName) \(secondName): \(type)"
        } else {
            return "\(firstName): \(type)"
        }
    }

    // MARK: - Doc Comment Extraction

    private static func extractDocComment(from decl: some SyntaxProtocol) -> DocComment {
        let trivia = decl.leadingTrivia
        var docLines: [String] = []

        for piece in trivia {
            switch piece {
            case let .docLineComment(text):
                let cleaned = text.trimmingCharacters(in: .whitespaces)
                if cleaned.hasPrefix("///") {
                    let line = String(cleaned.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    // Include empty lines to preserve document structure for code blocks
                    docLines.append(line)
                }
            case let .docBlockComment(text):
                let cleaned = text
                    .replacingOccurrences(of: "/**", with: "")
                    .replacingOccurrences(of: "*/", with: "")
                // Split by lines and process each, preserving structure
                let blockLines = cleaned.components(separatedBy: .newlines)
                for blockLine in blockLines {
                    let trimmed = blockLine
                        .trimmingCharacters(in: .whitespaces)
                        .replacingOccurrences(of: "^\\*\\s*", with: "", options: .regularExpression)
                    docLines.append(trimmed)
                }
            default:
                break
            }
        }

        let rawComment = docLines.isEmpty ? nil : docLines.joined(separator: "\n")
        return DocCommentParser.parse(rawComment)
    }
}
