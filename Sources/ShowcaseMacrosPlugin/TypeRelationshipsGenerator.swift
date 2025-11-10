// TypeRelationshipsGenerator.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/10/25.
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

/// Generates Type Relationships section showing inheritance, conformances, and constraints.
enum TypeRelationshipsGenerator {
    static func generate(typeInfo: TypeInfo) -> String {
        let declaration = buildDeclaration(typeInfo: typeInfo)

        return """
        CodeBlock("Type Relationships") {
        \"\"\"
        \(declaration)
        \"\"\"
        }
        """
    }

    private static func buildDeclaration(typeInfo: TypeInfo) -> String {
        var declaration = "struct "

        // Add type name with generics
        if let genericParams = typeInfo.genericParameters {
            declaration += "\(typeInfo.name)\(genericParams)"
        } else {
            declaration += typeInfo.name
        }

        // Add inheritance
        let inheritanceList = categorizeInheritance(typeInfo: typeInfo)
        if !inheritanceList.isEmpty {
            declaration += ": \(inheritanceList.joined(separator: ", "))"
        }

        // Add where clause
        if !typeInfo.genericConstraints.isEmpty {
            declaration += " where \(typeInfo.genericConstraints.joined(separator: ", "))"
        }

        return declaration
    }

    private static func categorizeInheritance(typeInfo: TypeInfo) -> [String] {
        var protocols: [String] = []
        var superclass: String?

        for inheritedType in typeInfo.inheritedTypes {
            if isProtocol(inheritedType) {
                protocols.append(inheritedType)
            } else {
                // Assume it's a superclass if we don't have one yet
                if superclass == nil {
                    superclass = inheritedType
                } else {
                    // Multiple base classes not allowed, treat as protocol
                    protocols.append(inheritedType)
                }
            }
        }

        var result: [String] = []
        if let superclass = superclass {
            result.append(superclass)
        }
        result.append(contentsOf: protocols)

        return result
    }

    private static func isProtocol(_ typeName: String) -> Bool {
        // LIMITATION: Swift macros operate on syntax trees without access to semantic type information.
        // This heuristic uses naming patterns to distinguish protocols from classes, which may produce
        // false positives (e.g., classes ending in "able") or false negatives (protocols with non-standard names).
        //
        // Why this limitation exists:
        // - Macros expand during compilation before type checking completes
        // - No access to module resolution or type metadata at macro expansion time
        //
        // Potential solutions (not implemented):
        // - Use `#externalMacro` with a compiler plugin that has semantic access
        // - Parse explicit `protocol` keyword in the source (requires declaration context)
        // - Maintain a comprehensive allowlist of Swift stdlib/framework protocol names
        //
        // Current approach is "good enough" for common SwiftUI/Foundation types.
        let protocolPatterns = [
            "able", "Protocol", "View", "Equatable", "Hashable",
            "Codable", "Identifiable", "ObservableObject", "Sendable",
        ]

        return protocolPatterns.contains { pattern in
            typeName.hasSuffix(pattern) || typeName == pattern
        }
    }
}
