// ShowcasableMacro.swift
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

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

/// Macro that generates showcase documentation for a type.
public struct ShowcasableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        // Extract macro arguments
        let arguments = try MacroArguments.extract(from: node)

        // Extract type information
        let typeInfo = try TypeInfo.extract(from: declaration)

        // Extract documentation
        let documentation = DocumentationExtractor.extract(from: declaration)

        // Find manually marked content
        let examples = ExampleFinder.findExamples(in: declaration)
        let codeBlocks = ExampleFinder.findCodeBlocks(in: declaration)
        let links = ExampleFinder.findLinks(in: declaration)
        let descriptions = ExampleFinder.findDescriptions(in: declaration)

        // Auto-discover members if enabled
        let initializers = arguments.autoDiscover ? MemberDiscovery.findInitializers(in: declaration) : []
        let methods = arguments.autoDiscover ? MemberDiscovery.findMethods(in: declaration) : []
        let properties = arguments.autoDiscover ? MemberDiscovery.findProperties(in: declaration) : []

        // Prepare configuration structures
        let config = TopicConfiguration(
            typeInfo: typeInfo,
            chapter: arguments.chapter,
            icon: arguments.icon,
            autoDiscover: arguments.autoDiscover
        )

        let docs = TopicDocumentation(
            documentation: documentation,
            examples: examples,
            codeBlocks: codeBlocks,
            links: links,
            descriptions: descriptions
        )

        let members = TopicMembers(
            initializers: initializers,
            methods: methods,
            properties: properties
        )

        // Generate the extension code
        let (showcaseTopicDecl, chapterDecl) = CodeGenerator.generateMembers(
            config: config,
            docs: docs,
            members: members
        )

        let showcasableType = TypeSyntax(stringLiteral: "Showcasable")

        return try [ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: showcasableType)
            },
            memberBlock: MemberBlockSyntax(members: [
                MemberBlockItemSyntax(decl: showcaseTopicDecl),
                MemberBlockItemSyntax(decl: chapterDecl),
            ])
        )]
    }
}
