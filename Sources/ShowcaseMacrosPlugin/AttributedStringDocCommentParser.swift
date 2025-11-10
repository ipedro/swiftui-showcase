// AttributedStringDocCommentParser.swift
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

/// Parses Swift documentation comments using a hybrid approach:
/// - AttributedString for robust code block extraction
/// - Manual parsing for Swift-specific sections (Parameters, Returns, etc.)
enum AttributedStringDocCommentParser {
    
    /// Extracts content parts (text and code blocks) from a raw doc comment string.
    /// Uses regex to detect code blocks while preserving original markdown formatting.
    /// Returns array of ContentPart preserving declaration order.
    static func extractContentParts(from rawComment: String) -> [ContentPart] {
        // Strategy: Use regex to find code blocks (```) directly in the raw string
        // This preserves all markdown formatting instead of parsing it
        
        let pattern = "```[a-z]*\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [.text(rawComment)]
        }
        
        let nsString = rawComment as NSString
        let matches = regex.matches(in: rawComment, range: NSRange(location: 0, length: nsString.length))
        
        guard !matches.isEmpty else {
            // No code blocks found - return entire string as text
            return [.text(rawComment)]
        }
        
        var contentParts: [ContentPart] = []
        var currentIndex = 0
        
        for match in matches {
            let matchRange = match.range
            
            // Add text before this code block
            if currentIndex < matchRange.location {
                let textRange = NSRange(location: currentIndex, length: matchRange.location - currentIndex)
                var text = nsString.substring(with: textRange)
                
                // Clean up text: normalize indentation but preserve markdown structure
                text = normalizeTextIndentation(text)
                
                if !text.isEmpty {
                    contentParts.append(.text(text))
                }
            }
            
            // Extract code block content (group 1 - content between ```)
            if match.numberOfRanges > 1 {
                let codeRange = match.range(at: 1)
                let code = nsString.substring(with: codeRange)
                let normalized = normalizeIndentation(code)
                if !normalized.isEmpty {
                    contentParts.append(.codeBlock(normalized))
                }
            }
            
            currentIndex = matchRange.location + matchRange.length
        }
        
        // Add remaining text after last code block
        if currentIndex < nsString.length {
            let textRange = NSRange(location: currentIndex, length: nsString.length - currentIndex)
            var text = nsString.substring(with: textRange)
            text = normalizeTextIndentation(text)
            if !text.isEmpty {
                contentParts.append(.text(text))
            }
        }
        
        return contentParts
    }
    
    /// Normalizes text indentation while preserving markdown structure (headers, lists, etc.)
    private static func normalizeTextIndentation(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        
        // Find minimum indentation (excluding empty lines and lines that should keep indent like list items)
        let minIndent = lines
            .filter { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                // Skip empty lines and lines that start with markdown syntax that needs indentation
                return !trimmed.isEmpty
            }
            .compactMap { line -> Int? in
                // Count leading spaces/tabs
                let leadingSpaces = line.prefix(while: { $0 == " " || $0 == "\t" }).count
                return leadingSpaces
            }
            .min() ?? 0
        
        // Remove common indentation from all lines
        let normalized = lines.map { line -> String in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else {
                return "" // Empty lines stay empty
            }
            // Remove minIndent characters from start
            let start = line.index(line.startIndex, offsetBy: min(minIndent, line.count))
            return String(line[start...])
        }.joined(separator: "\n")
        
        // Only trim excessive leading/trailing newlines, but preserve paragraph structure
        // Trim leading newlines completely
        var result = normalized
        while result.hasPrefix("\n") {
            result = String(result.dropFirst())
        }
        // Trim trailing newlines completely
        while result.hasSuffix("\n") {
            result = String(result.dropLast())
        }
        // Trim any other leading/trailing whitespace
        return result.trimmingCharacters(in: .whitespaces)
    }
    
    /// Normalizes code block indentation by removing common leading whitespace
    private static func normalizeIndentation(_ code: String) -> String {
        let lines = code.components(separatedBy: .newlines)
        
        // Find minimum indentation (excluding empty lines)
        let minIndent = lines
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .compactMap { line -> Int? in
                let leadingSpaces = line.prefix(while: { $0 == " " || $0 == "\t" }).count
                return leadingSpaces
            }
            .min() ?? 0
        
        // Remove common indentation from all lines
        let normalized = lines.map { line -> String in
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else {
                return "" // Empty lines become truly empty
            }
            // Remove minIndent characters from start
            let start = line.index(line.startIndex, offsetBy: min(minIndent, line.count))
            return String(line[start...])
        }.joined(separator: "\n")
        
        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
