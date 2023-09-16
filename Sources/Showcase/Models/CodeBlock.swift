//  Copyright (c) 2023 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation

/// Represents a code block associated with a showcase element.
public struct CodeBlock: Identifiable, RawRepresentable, ExpressibleByStringLiteral {
    /// The unique identifier for the code block.
    public var id: String { rawValue }
    
    /// The raw string value of the code block.
    public var rawValue: String
    
    /// Optional title for the code block.
    public var title: String?
    
    /// Initializes a code block from raw text.
    public init?(rawValue: String) {
        self.title = nil
        self.rawValue = rawValue
    }
    
    /// Initializes a code block with a title and raw text.
    /// - Parameters:
    ///   - title: Optional title for the code block.
    ///   - text: A closure returning the raw text content of the code block.
    public init(_ title: String? = nil, text: () -> String) {
        self.title = title
        self.rawValue = text()
    }

    /// Initializes a code block using a string literal.
    /// - Parameter value: The string literal representing the code block's raw content.
    public init(stringLiteral value: String) {
        title = nil
        rawValue = value
    }
}

/// A result builder for creating code blocks.
@resultBuilder public struct CodeBlockBuilder {
    /// Builds an array of code blocks from individual components.
    public static func buildBlock() -> [CodeBlock] { [] }
    
    /// Builds an array of code blocks from variadic components.
    public static func buildBlock(_ components: CodeBlock...) -> [CodeBlock] { components }
    
    /// Builds an array of code blocks from variadic string components.
    public static func buildBlock(_ components: String...) -> [CodeBlock] { components.map { .init(stringLiteral: $0) } }
}
