// TopicConfiguration.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/09/25.
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

/// Configuration for topic generation.
struct TopicConfiguration {
    let typeInfo: TypeInfo
    let icon: String?
    let autoDiscover: Bool
}

/// Documentation content for topic generation.
struct TopicDocumentation {
    let documentation: Documentation
    let examples: [ExampleInfo]
    let codeBlocks: [CodeBlockInfo]
    let links: [LinkInfo]
    let descriptions: [String]
}

/// Discovered API members for topic generation.
struct TopicMembers {
    let initializers: [InitializerInfo]
    let methods: [MethodInfo]
    let properties: [PropertyInfo]
}
