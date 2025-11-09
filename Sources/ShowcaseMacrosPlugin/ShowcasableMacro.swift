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
        
        // Always find manually marked content (regardless of autoDiscover)
        let examples = ExampleFinder.findExamples(in: declaration)
        let codeBlocks = ExampleFinder.findCodeBlocks(in: declaration)
        let links = ExampleFinder.findLinks(in: declaration)
        let descriptions = ExampleFinder.findDescriptions(in: declaration)
        
        // Auto-discover members for API reference only if enabled
        let initializers = arguments.autoDiscover ? MemberDiscovery.findInitializers(in: declaration) : []
        let methods = arguments.autoDiscover ? MemberDiscovery.findMethods(in: declaration) : []
        let properties = arguments.autoDiscover ? MemberDiscovery.findProperties(in: declaration) : []
        
        // Generate the extension code
        let (showcaseTopicDecl, chapterDecl) = CodeGenerator.generateMembers(
            typeInfo: typeInfo,
            chapter: arguments.chapter,
            icon: arguments.icon,
            documentation: documentation,
            examples: examples,
            codeBlocks: codeBlocks,
            links: links,
            descriptions: descriptions,
            initializers: initializers,
            methods: methods,
            properties: properties,
            autoDiscover: arguments.autoDiscover
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
    let inheritedTypes: [String]
    let genericConstraints: [String]
    
    static func extract(from declaration: some DeclGroupSyntax) throws -> TypeInfo {
        // Extract type name based on declaration kind
        let name: String
        let genericParams: String?
        let inheritedTypes: [String]
        let constraints: [String]
        
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            name = structDecl.name.text
            genericParams = structDecl.genericParameterClause?.description.trimmingCharacters(in: .whitespaces)
            inheritedTypes = extractInheritedTypes(from: structDecl.inheritanceClause)
            constraints = extractGenericConstraints(from: structDecl.genericWhereClause)
        } else if let classDecl = declaration.as(ClassDeclSyntax.self) {
            name = classDecl.name.text
            genericParams = classDecl.genericParameterClause?.description.trimmingCharacters(in: .whitespaces)
            inheritedTypes = extractInheritedTypes(from: classDecl.inheritanceClause)
            constraints = extractGenericConstraints(from: classDecl.genericWhereClause)
        } else if let enumDecl = declaration.as(EnumDeclSyntax.self) {
            name = enumDecl.name.text
            genericParams = enumDecl.genericParameterClause?.description.trimmingCharacters(in: .whitespaces)
            inheritedTypes = extractInheritedTypes(from: enumDecl.inheritanceClause)
            constraints = extractGenericConstraints(from: enumDecl.genericWhereClause)
        } else {
            throw MacroError.unsupportedDeclarationType
        }
        
        return TypeInfo(
            name: name,
            genericParameters: genericParams,
            inheritedTypes: inheritedTypes,
            genericConstraints: constraints
        )
    }
    
    private static func extractInheritedTypes(from clause: InheritanceClauseSyntax?) -> [String] {
        guard let clause = clause else { return [] }
        
        return clause.inheritedTypes.map { inheritedType in
            inheritedType.type.description.trimmingCharacters(in: .whitespaces)
        }
    }
    
    private static func extractGenericConstraints(from clause: GenericWhereClauseSyntax?) -> [String] {
        guard let clause = clause else { return [] }
        
        return clause.requirements.map { requirement in
            requirement.description.trimmingCharacters(in: .whitespaces)
        }
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
    
    static func findCodeBlocks(in declaration: some DeclGroupSyntax) -> [CodeBlockInfo] {
        var codeBlocks: [CodeBlockInfo] = []
        
        for member in declaration.memberBlock.members {
            // Skip hidden members
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseHidden") {
                continue
            }
            
            // Check if member has @ShowcaseCodeBlock attribute
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseCodeBlock"),
               let binding = varDecl.bindings.first {
                
                // Extract title from attribute
                let title = extractCodeBlockTitle(from: varDecl)
                
                // Extract string literal value from initializer
                if let initializer = binding.initializer,
                   let stringLiteral = initializer.value.as(StringLiteralExprSyntax.self) {
                    let code = extractStringLiteralContent(from: stringLiteral)
                    
                    codeBlocks.append(CodeBlockInfo(
                        title: title ?? "Code",
                        code: code
                    ))
                }
            }
        }
        
        return codeBlocks
    }
    
    static func findLinks(in declaration: some DeclGroupSyntax) -> [LinkInfo] {
        var links: [LinkInfo] = []
        
        for member in declaration.memberBlock.members {
            // Skip hidden members
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseHidden") {
                continue
            }
            
            // Check if member has @ShowcaseLink attribute
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseLink") {
                
                // Extract title and url from attribute
                let (title, url) = extractLinkMetadata(from: varDecl)
                
                if let title = title, let url = url {
                    links.append(LinkInfo(
                        title: title,
                        url: url
                    ))
                }
            }
        }
        
        return links
    }
    
    static func findDescriptions(in declaration: some DeclGroupSyntax) -> [String] {
        var descriptions: [String] = []
        
        for member in declaration.memberBlock.members {
            // Skip hidden members
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseHidden") {
                continue
            }
            
            // Check if member has @ShowcaseDescription attribute
            if let varDecl = member.decl.as(VariableDeclSyntax.self),
               varDecl.hasAttribute(named: "ShowcaseDescription") {
                
                // Extract description text from attribute
                if let description = extractDescriptionText(from: varDecl) {
                    descriptions.append(description)
                }
            }
        }
        
        return descriptions
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
    
    private static func extractCodeBlockTitle(from varDecl: VariableDeclSyntax) -> String? {
        guard let attr = varDecl.attributes.first(where: { attr in
            attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ShowcaseCodeBlock"
        })?.as(AttributeSyntax.self) else {
            return nil
        }
        
        guard let arguments = attr.arguments?.as(LabeledExprListSyntax.self) else {
            return nil
        }
        
        for argument in arguments {
            if argument.label?.text == "title",
               let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
               let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                return segment.content.text
            }
        }
        
        return nil
    }
    
    private static func extractLinkMetadata(from varDecl: VariableDeclSyntax) -> (title: String?, url: String?) {
        guard let attr = varDecl.attributes.first(where: { attr in
            attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ShowcaseLink"
        })?.as(AttributeSyntax.self) else {
            return (nil, nil)
        }
        
        guard let arguments = attr.arguments?.as(LabeledExprListSyntax.self) else {
            return (nil, nil)
        }
        
        var title: String?
        var url: String?
        
        for argument in arguments {
            let label = argument.label?.text
            
            if let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
               let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                let value = segment.content.text
                
                // First unlabeled argument is title
                if label == nil && title == nil {
                    title = value
                } else if label == "url" {
                    url = value
                }
            }
        }
        
        return (title, url)
    }
    
    private static func extractDescriptionText(from varDecl: VariableDeclSyntax) -> String? {
        guard let attr = varDecl.attributes.first(where: { attr in
            attr.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ShowcaseDescription"
        })?.as(AttributeSyntax.self) else {
            return nil
        }
        
        guard let arguments = attr.arguments?.as(LabeledExprListSyntax.self) else {
            return nil
        }
        
        // Get first string argument (unlabeled)
        if let firstArg = arguments.first,
           firstArg.label == nil,
           let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
           let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
            return segment.content.text
        }
        
        return nil
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

struct ExampleInfo {
    let name: String
    let title: String
    let description: String?
}

struct CodeBlockInfo {
    let title: String
    let code: String
}

struct LinkInfo {
    let title: String
    let url: String
}

// MARK: - Member Discovery

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
            
            // Check if public/internal
            let isPublic = initDecl.modifiers.contains { modifier in
                modifier.name.text == "public" || modifier.name.text == "internal"
            }
            
            // Default to internal if no modifier
            let hasNoAccessModifier = !initDecl.modifiers.contains { modifier in
                ["public", "internal", "private", "fileprivate"].contains(modifier.name.text)
            }
            
            guard isPublic || hasNoAccessModifier else {
                continue
            }
            
            // Extract signature
            let signature = extractInitializerSignature(from: initDecl)
            
            // Extract doc comment
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
            
            // Check if public/internal
            let isPublic = funcDecl.modifiers.contains { modifier in
                modifier.name.text == "public" || modifier.name.text == "internal"
            }
            
            let hasNoAccessModifier = !funcDecl.modifiers.contains { modifier in
                ["public", "internal", "private", "fileprivate"].contains(modifier.name.text)
            }
            
            guard isPublic || hasNoAccessModifier else {
                continue
            }
            
            // Check if static
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
            
            // Skip @ShowcaseExample marked properties (they're examples, not API)
            if varDecl.hasAttribute(named: "ShowcaseExample") {
                continue
            }
            
            // Skip @ShowcaseCodeBlock marked properties (they're code examples, not API)
            if varDecl.hasAttribute(named: "ShowcaseCodeBlock") {
                continue
            }
            
            // Skip @ShowcaseLink marked properties (they're documentation links, not API)
            if varDecl.hasAttribute(named: "ShowcaseLink") {
                continue
            }
            
            // Skip @ShowcaseDescription marked properties (they're documentation, not API)
            if varDecl.hasAttribute(named: "ShowcaseDescription") {
                continue
            }
            
            // Check if public/internal
            let isPublic = varDecl.modifiers.contains { modifier in
                modifier.name.text == "public" || modifier.name.text == "internal"
            }
            
            let hasNoAccessModifier = !varDecl.modifiers.contains { modifier in
                ["public", "internal", "private", "fileprivate"].contains(modifier.name.text)
            }
            
            guard isPublic || hasNoAccessModifier else {
                continue
            }
            
            // Check if static
            let isStatic = varDecl.modifiers.contains { modifier in
                modifier.name.text == "static" || modifier.name.text == "class"
            }
            
            // Extract property info
            for binding in varDecl.bindings {
                guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                    continue
                }
                
                // Skip SwiftUI View's body property - it's implementation detail, not API
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
    
    // MARK: - Signature Extraction
    
    private static func extractInitializerSignature(from initDecl: InitializerDeclSyntax) -> String {
        var signature = "init"
        
        // Add parameters
        let params = initDecl.signature.parameterClause.parameters
        if params.isEmpty {
            signature += "()"
        } else {
            let paramStrings = params.map { param -> String in
                let firstName = param.firstName.text
                let secondName = param.secondName?.text
                let type = param.type.description.trimmingCharacters(in: .whitespaces)
                
                if let secondName = secondName {
                    return "\(firstName) \(secondName): \(type)"
                } else {
                    return "\(firstName): \(type)"
                }
            }
            signature += "(" + paramStrings.joined(separator: ", ") + ")"
        }
        
        return signature
    }
    
    private static func extractMethodSignature(from funcDecl: FunctionDeclSyntax) -> String {
        var signature = funcDecl.name.text
        
        // Add parameters
        let params = funcDecl.signature.parameterClause.parameters
        if params.isEmpty {
            signature += "()"
        } else {
            let paramStrings = params.map { param -> String in
                let firstName = param.firstName.text
                let secondName = param.secondName?.text
                let type = param.type.description.trimmingCharacters(in: .whitespaces)
                
                if let secondName = secondName {
                    return "\(firstName) \(secondName): \(type)"
                } else {
                    return "\(firstName): \(type)"
                }
            }
            signature += "(" + paramStrings.joined(separator: ", ") + ")"
        }
        
        // Add return type
        if let returnType = funcDecl.signature.returnClause?.type {
            signature += " -> \(returnType.description.trimmingCharacters(in: .whitespaces))"
        }
        
        return signature
    }
    
    // MARK: - Doc Comment Extraction
    
    private static func extractDocComment(from decl: some SyntaxProtocol) -> DocComment {
        // Extract leading trivia (comments before the declaration)
        let trivia = decl.leadingTrivia
        var docLines: [String] = []
        
        for piece in trivia {
            switch piece {
            case .docLineComment(let text):
                // Remove /// prefix
                let cleaned = text.trimmingCharacters(in: .whitespaces)
                if cleaned.hasPrefix("///") {
                    let line = String(cleaned.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                    if !line.isEmpty {
                        docLines.append(line)
                    }
                }
            case .docBlockComment(let text):
                // Remove /** */ wrapper
                let cleaned = text
                    .replacingOccurrences(of: "/**", with: "")
                    .replacingOccurrences(of: "*/", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                if !cleaned.isEmpty {
                    docLines.append(cleaned)
                }
            default:
                break
            }
        }
        
        let rawComment = docLines.isEmpty ? nil : docLines.joined(separator: "\n")
        return DocCommentParser.parse(rawComment)
    }
}

// MARK: - Structured Doc Comments

/// Represents a parsed documentation comment with structured sections.
struct DocComment {
    /// The summary (first paragraph)
    let summary: String?
    
    /// Extended discussion (middle paragraphs before special sections)
    let discussion: String?
    
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
}

/// Parses Swift documentation comments into structured data.
enum DocCommentParser {
    /// Parses a raw doc comment string into structured DocComment.
    static func parse(_ rawComment: String?) -> DocComment {
        guard let raw = rawComment else {
            return DocComment(
                summary: nil,
                discussion: nil,
                parameters: [:],
                returns: nil,
                throws: nil,
                notes: [],
                warnings: [],
                important: []
            )
        }
        
        // Split into lines
        let lines = raw.components(separatedBy: .newlines)
        
        var summary: String?
        var discussionLines: [String] = []
        var parameters: [String: String] = [:]
        var returns: String?
        var throwsInfo: String?
        var notes: [String] = []
        var warnings: [String] = []
        var important: [String] = []
        
        var currentSection: Section = .summary
        var currentParam: String?
        var currentParamLines: [String] = []
        
        enum Section {
            case summary, discussion, parameters, returns, `throws`, note, warning, important
        }
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            // Detect section markers
            if trimmed.hasPrefix("- Parameter ") || trimmed.hasPrefix("- parameter ") {
                // Save previous parameter if any
                if let param = currentParam, !currentParamLines.isEmpty {
                    parameters[param] = currentParamLines.joined(separator: " ")
                    currentParamLines = []
                }
                
                // Extract parameter name and description
                let parts = trimmed.dropFirst("- Parameter ".count).components(separatedBy: ":")
                if parts.count >= 2 {
                    currentParam = parts[0].trimmingCharacters(in: .whitespaces)
                    let desc = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                    currentParamLines.append(desc)
                }
                currentSection = .parameters
                continue
            } else if trimmed.hasPrefix("- Parameters:") || trimmed.hasPrefix("- parameters:") {
                currentSection = .parameters
                continue
            } else if trimmed.hasPrefix("- Returns:") || trimmed.hasPrefix("- returns:") {
                let desc = trimmed.dropFirst("- Returns:".count).trimmingCharacters(in: .whitespaces)
                returns = desc.isEmpty ? nil : desc
                currentSection = .returns
                continue
            } else if trimmed.hasPrefix("- Throws:") || trimmed.hasPrefix("- throws:") {
                let desc = trimmed.dropFirst("- Throws:".count).trimmingCharacters(in: .whitespaces)
                throwsInfo = desc.isEmpty ? nil : desc
                currentSection = .throws
                continue
            } else if trimmed.hasPrefix("- Note:") || trimmed.hasPrefix("- note:") {
                let desc = trimmed.dropFirst("- Note:".count).trimmingCharacters(in: .whitespaces)
                if !desc.isEmpty {
                    notes.append(desc)
                }
                currentSection = .note
                continue
            } else if trimmed.hasPrefix("- Warning:") || trimmed.hasPrefix("- warning:") {
                let desc = trimmed.dropFirst("- Warning:".count).trimmingCharacters(in: .whitespaces)
                if !desc.isEmpty {
                    warnings.append(desc)
                }
                currentSection = .warning
                continue
            } else if trimmed.hasPrefix("- Important:") || trimmed.hasPrefix("- important:") {
                let desc = trimmed.dropFirst("- Important:".count).trimmingCharacters(in: .whitespaces)
                if !desc.isEmpty {
                    important.append(desc)
                }
                currentSection = .important
                continue
            }
            
            // Handle nested parameter lists (indented under - Parameters:)
            if currentSection == .parameters && trimmed.hasPrefix("- ") {
                // Save previous parameter if any
                if let param = currentParam, !currentParamLines.isEmpty {
                    parameters[param] = currentParamLines.joined(separator: " ")
                    currentParamLines = []
                }
                
                // Parse nested parameter
                let parts = trimmed.dropFirst(2).components(separatedBy: ":")
                if parts.count >= 2 {
                    currentParam = parts[0].trimmingCharacters(in: .whitespaces)
                    let desc = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
                    currentParamLines.append(desc)
                }
                continue
            }
            
            // Add content to current section
            if trimmed.isEmpty {
                // Empty line - might transition from summary to discussion
                if currentSection == .summary && summary != nil {
                    currentSection = .discussion
                }
                continue
            }
            
            switch currentSection {
            case .summary:
                if summary == nil {
                    summary = trimmed
                } else {
                    summary! += " " + trimmed
                }
            case .discussion:
                discussionLines.append(trimmed)
            case .parameters:
                // Continuation of parameter description
                if currentParam != nil {
                    currentParamLines.append(trimmed)
                }
            case .returns:
                if returns == nil {
                    returns = trimmed
                } else {
                    returns! += " " + trimmed
                }
            case .throws:
                if throwsInfo == nil {
                    throwsInfo = trimmed
                } else {
                    throwsInfo! += " " + trimmed
                }
            case .note:
                if !notes.isEmpty {
                    notes[notes.count - 1] += " " + trimmed
                }
            case .warning:
                if !warnings.isEmpty {
                    warnings[warnings.count - 1] += " " + trimmed
                }
            case .important:
                if !important.isEmpty {
                    important[important.count - 1] += " " + trimmed
                }
            }
        }
        
        // Save last parameter if any
        if let param = currentParam, !currentParamLines.isEmpty {
            parameters[param] = currentParamLines.joined(separator: " ")
        }
        
        let discussion = discussionLines.isEmpty ? nil : discussionLines.joined(separator: " ")
        
        return DocComment(
            summary: summary,
            discussion: discussion,
            parameters: parameters,
            returns: returns,
            throws: throwsInfo,
            notes: notes,
            warnings: warnings,
            important: important
        )
    }
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

/// Generates the extension code.
enum CodeGenerator {
    /// Generates API Reference section from discovered members.
    /// Generates Type Relationships section showing inheritance, conformances, and constraints.
    private static func generateTypeRelationships(typeInfo: TypeInfo) -> String {
        var lines: [String] = []
        
        // Separate inherited types into protocols and classes
        var protocols: [String] = []
        var superclass: String?
        
        // Heuristic: if it starts with uppercase and doesn't contain protocol-like patterns, it's likely a class
        // This is a simplification - in real code, we'd need more context
        for inheritedType in typeInfo.inheritedTypes {
            // Common protocol patterns
            if inheritedType.hasSuffix("able") || 
               inheritedType.hasSuffix("Protocol") ||
               inheritedType == "View" ||
               inheritedType == "Equatable" ||
               inheritedType == "Hashable" ||
               inheritedType == "Codable" ||
               inheritedType == "Identifiable" ||
               inheritedType == "ObservableObject" ||
               inheritedType == "Sendable" {
                protocols.append(inheritedType)
            } else {
                // Assume it's a superclass if we don't have one yet
                if superclass == nil {
                    superclass = inheritedType
                } else {
                    // Multiple base classes not allowed in Swift, so treat as protocol
                    protocols.append(inheritedType)
                }
            }
        }
        
        // Build the declaration line
        var declaration = "struct "
        if let genericParams = typeInfo.genericParameters {
            declaration += "\(typeInfo.name)\(genericParams)"
        } else {
            declaration += typeInfo.name
        }
        
        // Add inheritance
        var inheritanceList: [String] = []
        if let superclass = superclass {
            inheritanceList.append(superclass)
        }
        inheritanceList.append(contentsOf: protocols)
        
        if !inheritanceList.isEmpty {
            declaration += ": \(inheritanceList.joined(separator: ", "))"
        }
        
        // Add where clause if there are constraints
        if !typeInfo.genericConstraints.isEmpty {
            declaration += " where \(typeInfo.genericConstraints.joined(separator: ", "))"
        }
        
        lines.append(declaration)
        
        // Build the CodeBlock
        var content = "CodeBlock(title: \"Type Relationships\") {\n\"\"\"\n"
        content += lines.joined(separator: "\n")
        content += "\n\"\"\"\n}"
        
        return content
    }
    
    private static func generateAPIReference(
        initializers: [InitializerInfo],
        methods: [MethodInfo],
        properties: [PropertyInfo]
    ) -> String {
        var sections: [String] = []
        
        // Categorize methods
        let staticMethods = methods.filter { $0.isStatic }
        let instanceMethods = methods.filter { !$0.isStatic }
        
        // Categorize properties
        let staticProperties = properties.filter { $0.isStatic }
        let instanceProperties = properties.filter { !$0.isStatic }
        
        // 1. Creating Instances (Initializers)
        if !initializers.isEmpty {
            sections.append(generateInitializersSection(initializers))
        }
        
        // 2. Type Methods
        if !staticMethods.isEmpty {
            sections.append(generateMethodsSection(staticMethods, title: "Type Methods"))
        }
        
        // 3. Instance Methods
        if !instanceMethods.isEmpty {
            sections.append(generateMethodsSection(instanceMethods, title: "Instance Methods"))
        }
        
        // 4. Type Properties
        if !staticProperties.isEmpty {
            sections.append(generatePropertiesSection(staticProperties, title: "Type Properties"))
        }
        
        // 5. Instance Properties
        if !instanceProperties.isEmpty {
            sections.append(generatePropertiesSection(instanceProperties, title: "Instance Properties"))
        }
        
        return sections.joined(separator: "\n")
    }
    
    private static func generateInitializersSection(_ initializers: [InitializerInfo]) -> String {
        var content = "CodeBlock(title: \"Creating Instances\") {\n\"\"\"\n"
        for initializer in initializers {
            let doc = initializer.docComment
            if let summary = doc.summary {
                content += "/// \(summary)\n"
            }
            if !doc.parameters.isEmpty {
                for (name, desc) in doc.parameters.sorted(by: { $0.key < $1.key }) {
                    content += "/// - Parameter \(name): \(desc)\n"
                }
            }
            if let throwsInfo = doc.throws {
                content += "/// - Throws: \(throwsInfo)\n"
            }
            content += "\(initializer.signature)\n\n"
        }
        content += "\"\"\"\n}"
        return content
    }
    
    private static func generateMethodsSection(_ methods: [MethodInfo], title: String) -> String {
        var content = "CodeBlock(title: \"\(title)\") {\n\"\"\"\n"
        for method in methods {
            let doc = method.docComment
            if let summary = doc.summary {
                content += "/// \(summary)\n"
            }
            if !doc.parameters.isEmpty {
                for (name, desc) in doc.parameters.sorted(by: { $0.key < $1.key }) {
                    content += "/// - Parameter \(name): \(desc)\n"
                }
            }
            if let returns = doc.returns {
                content += "/// - Returns: \(returns)\n"
            }
            if let throwsInfo = doc.throws {
                content += "/// - Throws: \(throwsInfo)\n"
            }
            // Add static keyword for type methods
            let staticKeyword = method.isStatic ? "static " : ""
            content += "\(staticKeyword)func \(method.signature)\n\n"
        }
        content += "\"\"\"\n}"
        return content
    }
    
    private static func generatePropertiesSection(_ properties: [PropertyInfo], title: String) -> String {
        var content = "CodeBlock(title: \"\(title)\") {\n\"\"\"\n"
        for property in properties {
            let doc = property.docComment
            if let summary = doc.summary {
                content += "/// \(summary)\n"
            }
            // Add static keyword for type properties
            let staticKeyword = property.isStatic ? "static " : ""
            let keyword = property.isComputed ? "var" : "var"
            content += "\(staticKeyword)\(keyword) \(property.name): \(property.type)\n\n"
        }
        content += "\"\"\"\n}"
        return content
    }
    
    // Legacy method for backward compatibility - now delegates to categorized sections
    private static func generateAPIReference_Legacy(
        initializers: [InitializerInfo],
        methods: [MethodInfo],
        properties: [PropertyInfo]
    ) -> String {
        var sections: [String] = []
        
        // Generate Initializers section
        if !initializers.isEmpty {
            var initContent = "CodeBlock(title: \"Initializers\") {\n\"\"\"\n"
            for initializer in initializers {
                let doc = initializer.docComment
                if let summary = doc.summary {
                    initContent += "/// \(summary)\n"
                }
                if !doc.parameters.isEmpty {
                    for (name, desc) in doc.parameters.sorted(by: { $0.key < $1.key }) {
                        initContent += "/// - Parameter \(name): \(desc)\n"
                    }
                }
                if let throwsInfo = doc.throws {
                    initContent += "/// - Throws: \(throwsInfo)\n"
                }
                initContent += "\(initializer.signature)\n\n"
            }
            initContent += "\"\"\"\n}"
            sections.append(initContent)
        }
        
        // Generate Methods section
        if !methods.isEmpty {
            var methodContent = "CodeBlock(title: \"Methods\") {\n\"\"\"\n"
            for method in methods {
                let doc = method.docComment
                if let summary = doc.summary {
                    methodContent += "/// \(summary)\n"
                }
                if !doc.parameters.isEmpty {
                    for (name, desc) in doc.parameters.sorted(by: { $0.key < $1.key }) {
                        methodContent += "/// - Parameter \(name): \(desc)\n"
                    }
                }
                if let returns = doc.returns {
                    methodContent += "/// - Returns: \(returns)\n"
                }
                if let throwsInfo = doc.throws {
                    methodContent += "/// - Throws: \(throwsInfo)\n"
                }
                methodContent += "func \(method.signature)\n\n"
            }
            methodContent += "\"\"\"\n}"
            sections.append(methodContent)
        }
        
        // Generate Properties section
        if !properties.isEmpty {
            var propContent = "CodeBlock(title: \"Properties\") {\n\"\"\"\n"
            for property in properties {
                let doc = property.docComment
                if let summary = doc.summary {
                    propContent += "/// \(summary)\n"
                }
                let keyword = property.isComputed ? "var" : "var"
                propContent += "\(keyword) \(property.name): \(property.type)\n\n"
            }
            propContent += "\"\"\"\n}"
            sections.append(propContent)
        }
        
        return sections.joined(separator: "\n")
    }
    
    static func generateMembers(
        typeInfo: TypeInfo,
        chapter: String,
        icon: String?,
        documentation: Documentation,
        examples: [ExampleInfo],
        codeBlocks: [CodeBlockInfo],
        links: [LinkInfo],
        descriptions: [String],
        initializers: [InitializerInfo],
        methods: [MethodInfo],
        properties: [PropertyInfo],
        autoDiscover: Bool
    ) -> (showcaseTopic: DeclSyntax, chapter: DeclSyntax) {
        var topicContent: [String] = []
        
        // Add description from documentation if available
        if let summary = documentation.summary {
            topicContent.append("""
            Description {
                \"\"\"
                \(summary)
                \"\"\"
            }
            """)
        }
        
        // Add additional descriptions from @ShowcaseDescription
        for description in descriptions {
            topicContent.append("Description(\"\(description)\")")
        }
        
        // Add icon if provided
        if let icon {
            topicContent.append("Icon(Image(systemName: \"\(icon)\"))")
        }
        
        // Add Type Relationships section if auto-discover is enabled and there are any
        if autoDiscover && (!typeInfo.inheritedTypes.isEmpty || !typeInfo.genericConstraints.isEmpty) {
            topicContent.append(generateTypeRelationships(typeInfo: typeInfo))
        }
        
        // Add API Reference section if any members were discovered
        if !initializers.isEmpty || !methods.isEmpty || !properties.isEmpty {
            topicContent.append(generateAPIReference(
                initializers: initializers,
                methods: methods,
                properties: properties
            ))
        }
        
        // Add usage examples from doc comments
        for (index, usage) in documentation.usageExamples.enumerated() {
            topicContent.append("""
            CodeBlock(title: "Usage Example \(index + 1)") {
                \"\"\"
                \(usage)
                \"\"\"
            }
            """)
        }
        
        // Add code blocks from @ShowcaseCodeBlock
        for codeBlock in codeBlocks {
            let escapedCode = codeBlock.code
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
            topicContent.append("CodeBlock(title: \"\(codeBlock.title)\", code: \"\(escapedCode)\")")
        }
        
        // Add links from @ShowcaseLink
        for link in links {
            topicContent.append("Link(\"\(link.title)\", url: URL(string: \"\(link.url)\")!)")
        }
        
        // Add examples
        for example in examples {
            if let description = example.description {
                topicContent.append("""
                Example(title: "\(example.title)") {
                    Description("\(description)")
                    \(typeInfo.name).\(example.name)
                }
                """)
            } else {
                topicContent.append("""
                Example(title: "\(example.title)") {
                    \(typeInfo.name).\(example.name)
                }
                """)
            }
        }
        
        let content = topicContent.isEmpty ? " " : "\n\(topicContent.joined(separator: "\n"))\n"
        
        let showcaseTopicDecl = DeclSyntax(stringLiteral: """
            @MainActor public static var showcaseTopic: Topic {
                Topic("\(typeInfo.name)") {\(content)}
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

extension MemberBlockItemSyntax {
    func hasAttribute(named name: String) -> Bool {
        // Check the declaration's attributes
        if let varDecl = decl.as(VariableDeclSyntax.self) {
            return varDecl.hasAttribute(named: name)
        }
        if let funcDecl = decl.as(FunctionDeclSyntax.self) {
            return funcDecl.hasAttribute(named: name)
        }
        if let initDecl = decl.as(InitializerDeclSyntax.self) {
            return initDecl.hasAttribute(named: name)
        }
        return false
    }
}

extension FunctionDeclSyntax {
    func hasAttribute(named name: String) -> Bool {
        attributes.contains { attribute in
            attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name
        }
    }
}

extension InitializerDeclSyntax {
    func hasAttribute(named name: String) -> Bool {
        attributes.contains { attribute in
            attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name
        }
    }
}
