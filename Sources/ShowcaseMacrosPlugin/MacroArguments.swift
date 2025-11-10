// MacroArguments.swift
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

import SwiftSyntax

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
            let label = argument.label?.text
            let expr = argument.expression

            if label == nil, chapter == nil {
                // First unlabeled argument is chapter
                chapter = expr.stringLiteralValue
            } else if label == "chapter" {
                chapter = expr.stringLiteralValue
            } else if label == "icon" {
                icon = expr.stringLiteralValue
            } else if label == "order" {
                order = expr.integerLiteralValue
            } else if label == "autoDiscover" {
                autoDiscover = expr.booleanLiteralValue ?? true
            }
        }

        guard let chapter = chapter else {
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
