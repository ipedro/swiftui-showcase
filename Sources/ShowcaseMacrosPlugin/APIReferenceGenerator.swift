// APIReferenceGenerator.swift
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

import Foundation

/// Generates API Reference section from discovered members.
enum APIReferenceGenerator {
    static func generate(members: TopicMembers) -> String {
        var topics: [String] = []
        
        // Categorize members
        let staticMethods = members.methods.filter { $0.isStatic }
        let instanceMethods = members.methods.filter { !$0.isStatic }
        let staticProperties = members.properties.filter { $0.isStatic }
        let instanceProperties = members.properties.filter { !$0.isStatic }
        
        // Generate topics for each member type
        topics.append(contentsOf: members.initializers.map { generateInitializerTopic($0) })
        topics.append(contentsOf: staticMethods.map { generateMethodTopic($0) })
        topics.append(contentsOf: instanceMethods.map { generateMethodTopic($0) })
        topics.append(contentsOf: staticProperties.map { generatePropertyTopic($0) })
        topics.append(contentsOf: instanceProperties.map { generatePropertyTopic($0) })
        
        return topics.joined(separator: "\n")
    }
    
    // MARK: - Topic Generators
    
    private static func generateInitializerTopic(_ initializer: InitializerInfo) -> String {
        var content: [String] = []
        let doc = initializer.docComment
        
        if let summary = doc.summary {
            content.append(generateDescriptionBlock(summary))
        }
        
        // Add code blocks from doc comments
        for (index, codeBlock) in doc.codeBlocks.enumerated() {
            let title = doc.codeBlocks.count == 1 ? "Example" : "Example \(index + 1)"
            content.append(generateCodeBlock(title: title, code: codeBlock))
        }
        
        let signatureDoc = buildInitializerSignature(initializer: initializer)
        content.append(generateDeclarationBlock(signatureDoc))
        
        let topicContent = content.isEmpty ? "" : "\n\(content.joined(separator: "\n"))\n"
        let paramNames = extractParameterNames(from: initializer.signature)
        return "Topic(\"init\(paramNames)\") {\(topicContent)}"
    }
    
    private static func generateMethodTopic(_ method: MethodInfo) -> String {
        var content: [String] = []
        let doc = method.docComment
        
        if let summary = doc.summary {
            content.append(generateDescriptionBlock(summary))
        }
        
        // Add code blocks from doc comments
        for (index, codeBlock) in doc.codeBlocks.enumerated() {
            let title = doc.codeBlocks.count == 1 ? "Example" : "Example \(index + 1)"
            content.append(generateCodeBlock(title: title, code: codeBlock))
        }
        
        let signatureDoc = buildMethodSignature(method: method)
        content.append(generateDeclarationBlock(signatureDoc))
        
        let topicContent = content.isEmpty ? "" : "\n\(content.joined(separator: "\n"))\n"
        return "Topic(\"\(method.name)\") {\(topicContent)}"
    }
    
    private static func generatePropertyTopic(_ property: PropertyInfo) -> String {
        var content: [String] = []
        let doc = property.docComment
        
        if let summary = doc.summary {
            content.append(generateDescriptionBlock(summary))
        }
        
        // Add code blocks from doc comments
        for (index, codeBlock) in doc.codeBlocks.enumerated() {
            let title = doc.codeBlocks.count == 1 ? "Example" : "Example \(index + 1)"
            content.append(generateCodeBlock(title: title, code: codeBlock))
        }
        
        let signatureDoc = buildPropertySignature(property: property)
        content.append(generateDeclarationBlock(signatureDoc))
        
        let topicContent = content.isEmpty ? "" : "\n\(content.joined(separator: "\n"))\n"
        return "Topic(\"\(property.name)\") {\(topicContent)}"
    }
    
    // MARK: - Signature Builders
    
    private static func buildInitializerSignature(initializer: InitializerInfo) -> String {
        var signature = ""
        let doc = initializer.docComment
        
        if let summary = doc.summary {
            signature += "/// \(summary)\n"
        }
        
        for (name, desc) in doc.parameters.sorted(by: { $0.key < $1.key }) {
            signature += "/// - Parameter \(name): \(desc)\n"
        }
        
        if let throwsInfo = doc.throws {
            signature += "/// - Throws: \(throwsInfo)\n"
        }
        
        signature += initializer.signature
        return signature
    }
    
    private static func buildMethodSignature(method: MethodInfo) -> String {
        var signature = ""
        let doc = method.docComment
        
        if let summary = doc.summary {
            signature += "/// \(summary)\n"
        }
        
        for (name, desc) in doc.parameters.sorted(by: { $0.key < $1.key }) {
            signature += "/// - Parameter \(name): \(desc)\n"
        }
        
        if let returns = doc.returns {
            signature += "/// - Returns: \(returns)\n"
        }
        
        if let throwsInfo = doc.throws {
            signature += "/// - Throws: \(throwsInfo)\n"
        }
        
        let staticKeyword = method.isStatic ? "static " : ""
        signature += "\(staticKeyword)func \(method.signature)"
        return signature
    }
    
    private static func buildPropertySignature(property: PropertyInfo) -> String {
        var signature = ""
        let doc = property.docComment
        
        if let summary = doc.summary {
            signature += "/// \(summary)\n"
        }
        
        let staticKeyword = property.isStatic ? "static " : ""
        signature += "\(staticKeyword)var \(property.name): \(property.type)"
        return signature
    }
    
    // MARK: - Block Generators
    
    private static func generateDescriptionBlock(_ summary: String) -> String {
        """
        Description {
            \"\"\"
            \(summary)
            \"\"\"
        }
        """
    }
    
    private static func generateCodeBlock(title: String, code: String) -> String {
        let indented = code.replacingOccurrences(of: "\n", with: "\n            ")
        return """
        CodeBlock("\(title)") {
            \"\"\"
            \(indented)
            \"\"\"
        }
        """
    }
    
    private static func generateDeclarationBlock(_ signature: String) -> String {
        let indented = signature.replacingOccurrences(of: "\n", with: "\n            ")
        return """
        CodeBlock("Declaration") {
            \"\"\"
            \(indented)
            \"\"\"
        }
        """
    }
    
    // MARK: - Helper Functions
    
    private static func extractParameterNames(from signature: String) -> String {
        // Extract parameter labels from init signature like "init(id: String, name: String)"
        // Handles Swift parameter label syntax:
        // - "init(_ value: Int)" -> "init(_:)"
        // - "init(id: String)" -> "init(id:)"  
        // - "init(for key: String)" -> "init(for:)" (external label only)
        
        // Pattern explanation:
        // (_|\w+) - Match underscore OR word characters (external label or single label)
        // (?:\s+\w+)? - Optionally match whitespace + word (internal label, non-capturing)
        // \s*: - Match colon with optional whitespace
        let paramPattern = #"(_|\w+)(?:\s+\w+)?\s*:"#
        guard let regex = try? NSRegularExpression(pattern: paramPattern) else {
            return "()"
        }
        
        let nsString = signature as NSString
        let matches = regex.matches(in: signature, range: NSRange(location: 0, length: nsString.length))
        
        if matches.isEmpty {
            return "()"
        }
        
        let paramNames = matches.compactMap { match -> String? in
            guard match.numberOfRanges > 1 else { return nil }
            let range = match.range(at: 1)
            return nsString.substring(with: range)
        }
        
        return "(\(paramNames.map { "\($0):" }.joined()))"
    }
}
