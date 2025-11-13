// TypeInfo.swift
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

/// Information about a Swift type extracted from its declaration.
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
