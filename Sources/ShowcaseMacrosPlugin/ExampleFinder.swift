// ExampleFinder.swift
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
        var showCode: Bool = true
        
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
        
        if let firstArg = arguments.first,
           firstArg.label == nil,
           let stringLiteral = firstArg.expression.as(StringLiteralExprSyntax.self),
           let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
            return segment.content.text
        }
        
        return nil
    }
    
    // MARK: - Source Code Extraction
    
    private static func extractSourceCode(from binding: PatternBindingSyntax) -> String? {
        // Try to extract from accessor (computed property getter)
        if let accessorBlock = binding.accessorBlock,
           case .getter(let codeBlockItems) = accessorBlock.accessors {
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
