// TopicBuilder.swift
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

import Foundation

/// A result builder for creating code blocks.
@resultBuilder public struct TopicBuilder {
    public static func buildBlock(_ components: [Topic]...) -> [Topic] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [Topic]?) -> [Topic] {
        component ?? []
    }

    public static func buildEither(first component: [Topic]) -> [Topic] {
        component
    }

    public static func buildEither(second component: [Topic]) -> [Topic] {
        component
    }

    public static func buildArray(_ components: [[Topic]]) -> [Topic] {
        components.flatMap { $0 }
    }

    public static func buildLimitedAvailability(_ component: [Topic]) -> [Topic] {
        component
    }

    public static func buildExpression(_ expression: Topic) -> [Topic] {
        [expression]
    }

    public static func buildExpression(_ expression: [Topic]) -> [Topic] {
        expression
    }
}
