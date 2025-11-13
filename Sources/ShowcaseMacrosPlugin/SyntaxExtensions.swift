// SyntaxExtensions.swift
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

// MARK: - Literal Value Extraction

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

    /// Extracts type names from an array literal like [Type1.self, Type2.self]
    var arrayLiteralTypeNames: [String] {
        guard let arrayExpr = self.as(ArrayExprSyntax.self) else {
            return []
        }

        return arrayExpr.elements.compactMap { element in
            // Each element should be a MemberAccessExprSyntax for Type.self
            guard let memberAccess = element.expression.as(MemberAccessExprSyntax.self),
                  memberAccess.declName.baseName.text == "self",
                  let base = memberAccess.base
            else {
                return nil
            }

            // Extract the type name from the base
            return base.trimmedDescription
        }
    }
}

// MARK: - Attribute Checking

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
