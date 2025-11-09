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
        
        // Find all content if auto-discovery is enabled
        let examples = arguments.autoDiscover ? ExampleFinder.findExamples(in: declaration) : []
        let codeBlocks = arguments.autoDiscover ? ExampleFinder.findCodeBlocks(in: declaration) : []
        let links = arguments.autoDiscover ? ExampleFinder.findLinks(in: declaration) : []
        let descriptions = arguments.autoDiscover ? ExampleFinder.findDescriptions(in: declaration) : []
        
        // Auto-discover members for API reference
        let initializers = arguments.autoDiscover ? MemberDiscovery.findInitializers(in: declaration) : []
        let methods = arguments.autoDiscover ? MemberDiscovery.findMethods(in: declaration) : []
        let properties = arguments.autoDiscover ? MemberDiscovery.findProperties(in: declaration) : []
        
        // Generate the extension code
        let (showcaseTopicDecl, chapterDecl) = CodeGenerator.generateMembers(
            typeName: typeInfo.name,
            chapter: arguments.chapter,
            icon: arguments.icon,
            documentation: documentation,
            examples: examples,
            codeBlocks: codeBlocks,
            links: links,
            descriptions: descriptions,
            initializers: initializers,
            methods: methods,
            properties: properties
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
            
            let name = funcDecl.name.text
            let signature = extractMethodSignature(from: funcDecl)
            let docComment = extractDocComment(from: funcDecl)
            
            methods.append(MethodInfo(
                name: name,
                signature: signature,
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
            
            // Extract property info
            for binding in varDecl.bindings {
                guard let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
                    continue
                }
                
                let type = binding.typeAnnotation?.type.description.trimmingCharacters(in: .whitespaces) ?? "Unknown"
                let isComputed = binding.accessorBlock != nil
                let docComment = extractDocComment(from: varDecl)
                
                properties.append(PropertyInfo(
                    name: name,
                    type: type,
                    isComputed: isComputed,
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
    
    private static func extractDocComment(from decl: some SyntaxProtocol) -> String? {
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
        
        return docLines.isEmpty ? nil : docLines.joined(separator: " ")
    }
}

struct InitializerInfo {
    let signature: String
    let docComment: String?
}

struct MethodInfo {
    let name: String
    let signature: String
    let docComment: String?
}

struct PropertyInfo {
    let name: String
    let type: String
    let isComputed: Bool
    let docComment: String?
}

/// Generates the extension code.
enum CodeGenerator {
    /// Generates API Reference section from discovered members.
    private static func generateAPIReference(
        initializers: [InitializerInfo],
        methods: [MethodInfo],
        properties: [PropertyInfo]
    ) -> String {
        var sections: [String] = []
        
        // Generate Initializers section
        if !initializers.isEmpty {
            var initContent = "CodeBlock(title: \"Initializers\") {\n\"\"\"\n"
            for initializer in initializers {
                if let docComment = initializer.docComment {
                    initContent += "/// \(docComment)\n"
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
                if let docComment = method.docComment {
                    methodContent += "/// \(docComment)\n"
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
                if let docComment = property.docComment {
                    propContent += "/// \(docComment)\n"
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
        typeName: String,
        chapter: String,
        icon: String?,
        documentation: Documentation,
        examples: [ExampleInfo],
        codeBlocks: [CodeBlockInfo],
        links: [LinkInfo],
        descriptions: [String],
        initializers: [InitializerInfo],
        methods: [MethodInfo],
        properties: [PropertyInfo]
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
