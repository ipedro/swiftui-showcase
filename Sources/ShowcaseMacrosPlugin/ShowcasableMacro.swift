// ShowcasableMacro.swift
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
        
        // Find examples if auto-discovery is enabled
        let examples = arguments.autoDiscover ? ExampleFinder.findExamples(in: declaration) : []
        
        // Generate the extension code
        let (showcaseTopicDecl, chapterDecl) = CodeGenerator.generateMembers(
            typeName: typeInfo.name,
            chapter: arguments.chapter,
            icon: arguments.icon,
            documentation: documentation,
            examples: examples
        )
        
        let showcasableType = TypeSyntax(stringLiteral: "Showcasable")
        
        return [try ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: InheritanceClauseSyntax {
                InheritedTypeSyntax(type: showcasableType)
            },
            memberBlock: MemberBlockSyntax(members: [
                MemberBlockItemSyntax(decl: showcaseTopicDecl),
                MemberBlockItemSyntax(decl: chapterDecl)
            ])
        )]
    }
}

// MARK: - Supporting Types

/// Arguments extracted from the @Showcasable macro.
struct MacroArguments {
    let chapter: String
    let icon: String?
    let order: Int?
    let autoDiscover: Bool
    
    static func extract(from node: AttributeSyntax) throws -> MacroArguments {
        guard case let .argumentList(arguments) = node.arguments else {
            throw MacroError.missingArguments
        }
        
        var chapter: String?
        var icon: String?
        var order: Int?
        var autoDiscover = true
        
        for argument in arguments {
            guard let label = argument.label?.text else { continue }
            
            switch label {
            case "chapter":
                chapter = argument.expression.stringLiteralValue
            case "icon":
                icon = argument.expression.stringLiteralValue
            case "order":
                order = argument.expression.integerLiteralValue
            case "autoDiscover":
                autoDiscover = argument.expression.booleanLiteralValue ?? true
            default:
                break
            }
        }
        
        guard let chapter else {
            throw MacroError.missingChapterArgument
        }
        
        return MacroArguments(
            chapter: chapter,
            icon: icon,
            order: order,
            autoDiscover: autoDiscover
        )
    }
}

/// Information about the type being documented.
struct TypeInfo {
    let name: String
    let genericParameters: String?
    
    static func extract(from declaration: some DeclGroupSyntax) throws -> TypeInfo {
        // Extract type name based on declaration kind
        let name: String
        let genericParams: String?
        
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            name = structDecl.name.text
            genericParams = structDecl.genericParameterClause?.description.trimmingCharacters(in: .whitespaces)
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            name = classDecl.name.text
            genericParams = classDecl.genericParameterClause?.description.trimmingCharacters(in: .whitespaces)
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            name = enumDecl.name.text
            genericParams = enumDecl.genericParameterClause?.description.trimmingCharacters(in: .whitespaces)
        } else {
            throw MacroError.unsupportedDeclarationType
        }
        
        return TypeInfo(name: name, genericParameters: genericParams)
    }
}

/// Extracted documentation from code comments.
struct Documentation {
    let summary: String?
    let details: String?
    let usageExamples: [String]
    let notes: [String]
}

/// Extracts documentation from trivia (comments).
enum DocumentationExtractor {
    static func extract(from declaration: some DeclGroupSyntax) -> Documentation {
        // Extract leading trivia (comments before the declaration)
        let leadingTrivia = declaration.leadingTrivia
        
        var summary: String?
        var details: String?
        var usageExamples: [String] = []
        var notes: [String] = []
        
        var currentSection: String?
        var docLines: [String] = []
        
        for piece in leadingTrivia {
            if case let .docLineComment(comment) = piece {
                let line = comment.trimmingPrefix("///").trimmingCharacters(in: .whitespaces)
                
                // Check for section markers
                if line.hasPrefix("##") {
                    // Save previous section
                    if let section = currentSection {
                        saveSection(section, lines: docLines, to: &summary, &details, &usageExamples, &notes)
                    }
                    currentSection = line.trimmingPrefix("##").trimmingCharacters(in: .whitespaces)
                    docLines = []
                } else if !line.isEmpty {
                    docLines.append(line)
                }
            }
        }
        
        // Save last section
        if let section = currentSection {
            saveSection(section, lines: docLines, to: &summary, &details, &usageExamples, &notes)
        } else if !docLines.isEmpty {
            // No sections, treat as summary
            summary = docLines.joined(separator: " ")
        }
        
        return Documentation(
            summary: summary,
            details: details,
            usageExamples: usageExamples,
            notes: notes
        )
    }
    
    private static func saveSection(
        _ section: String,
        lines: [String],
        to summary: inout String?,
        _ details: inout String?,
        _ usageExamples: inout [String],
        _ notes: inout [String]
    ) {
        let content = lines.joined(separator: "\n")
        
        switch section.lowercased() {
        case "usage", "example", "examples":
            usageExamples.append(content)
        case "note", "notes", "important", "warning":
            notes.append(content)
        case "details", "description":
            details = content
        default:
            break
        }
    }
}

/// Finds @ShowcaseExample marked members.
enum ExampleFinder {
    static func findExamples(in declaration: some DeclGroupSyntax) -> [ExampleInfo] {
        var examples: [ExampleInfo] = []
        
        for member in declaration.memberBlock.members {
            // Check if member has @ShowcaseExample attribute
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseExample"),
               let binding = varDecl.bindings.first,
               let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                
                // Extract title and description from attribute
                let (title, description) = extractExampleMetadata(from: varDecl)
                
                examples.append(ExampleInfo(
                    name: name,
                    title: title ?? name,
                    description: description
                ))
            }
        }
        
        return examples
    }
    
    private static func extractExampleMetadata(from varDecl: VariableDeclSyntax) -> (title: String?, description: String?) {
        // Find the @ShowcaseExample attribute
        guard let exampleAttr = varDecl.attributes.first(where: { attr in
            attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ShowcaseExample"
        })?.as(AttributeSyntax.self) else {
            return (nil, nil)
        }
        
        // Extract arguments from the attribute
        guard let arguments = exampleAttr.arguments?.as(LabeledExprListSyntax.self) else {
            return (nil, nil)
        }
        
        var title: String?
        var description: String?
        
        for argument in arguments {
            let label = argument.label?.text
            
            // Extract string literal value
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
        }
        
        return (title, description)
    }
}

struct ExampleInfo {
    let name: String
    let title: String
    let description: String?
}

/// Generates the extension code.
enum CodeGenerator {
    static func generateMembers(
        typeName: String,
        chapter: String,
        icon: String?,
        documentation: Documentation,
        examples: [ExampleInfo]
    ) -> (showcaseTopic: DeclSyntax, chapter: DeclSyntax) {
        var topicContent: [String] = []
        
        // Add description if available
        if let summary = documentation.summary {
            topicContent.append("""
            Description {
                \"\"\"
                \(summary)
                \"\"\"
            }
            """)
        }
        
        // Add icon if provided
        if let icon {
            topicContent.append("Icon(Image(systemName: \"\(icon)\"))")
        }
        
        // Add usage examples from doc comments
        for (index, usage) in documentation.usageExamples.enumerated() {
            topicContent.append("""
            CodeBlock(language: .swift, title: "Usage Example \(index + 1)") {
                \"\"\"
                \(usage)
                \"\"\"
            }
            """)
        }
        
        // Add examples
        for example in examples {
            if let description = example.description {
                topicContent.append("""
                Example(title: "\(example.title)") {
                    Description("\(description)")
                    \(typeName).\(example.name)
                }
                """)
            } else {
                topicContent.append("""
                Example(title: "\(example.title)") {
                    \(typeName).\(example.name)
                }
                """)
            }
        }
        
        let content = topicContent.isEmpty ? " " : "\n\(topicContent.joined(separator: "\n"))\n"
        
        let showcaseTopicDecl = DeclSyntax(stringLiteral: """
            @MainActor public static var showcaseTopic: Topic {
                Topic("\(typeName)") {\(content)}
            }
            """)
        
        let chapterDecl = DeclSyntax(stringLiteral: """
            public static var showcaseChapter: String { "\(chapter)" }
            """)
        
        return (showcaseTopicDecl, chapterDecl)
    }
}

// MARK: - Errors

enum MacroError: Error, CustomStringConvertible {
    case missingArguments
    case missingChapterArgument
    case unsupportedDeclarationType
    
    var description: String {
        switch self {
        case .missingArguments:
            return "@Showcasable requires arguments"
        case .missingChapterArgument:
            return "@Showcasable requires a 'chapter' argument"
        case .unsupportedDeclarationType:
            return "@Showcasable can only be applied to struct, class, or enum"
        }
    }
}

// MARK: - Extensions

extension SyntaxProtocol {
    var stringLiteralValue: String? {
        if let stringLiteral = self.as(StringLiteralExprSyntax.self),
           stringLiteral.segments.count == 1,
           case let .stringSegment(segment) = stringLiteral.segments.first {
            return segment.content.text
        }
        return nil
    }
    
    var integerLiteralValue: Int? {
        if let intLiteral = self.as(IntegerLiteralExprSyntax.self),
           let value = Int(intLiteral.literal.text) {
            return value
        }
        return nil
    }
    
    var booleanLiteralValue: Bool? {
        if let boolLiteral = self.as(BooleanLiteralExprSyntax.self) {
            return boolLiteral.literal.tokenKind == .keyword(.true)
        }
        return nil
    }
}

extension VariableDeclSyntax {
    func hasAttribute(named name: String) -> Bool {
        attributes.contains { attribute in
            attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name
        }
    }
}
