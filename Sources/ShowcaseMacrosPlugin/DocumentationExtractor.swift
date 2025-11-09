// DocumentationExtractor.swift
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

/// Extracts documentation from trivia (comments).
enum DocumentationExtractor {
    static func extract(from declaration: some DeclGroupSyntax) -> Documentation {
        // Extract leading trivia (comments before the declaration)
        let leadingTrivia = declaration.leadingTrivia
        
        var summary: String?
        var details: String?
        var usageExamples: [String] = []
        var notes: [String] = []
        
        var currentSection: String?
        var docLines: [String] = []
        
        for piece in leadingTrivia {
            if case let .docLineComment(comment) = piece {
                let line = comment.trimmingPrefix("///").trimmingCharacters(in: .whitespaces)
                
                // Check for section markers
                if line.hasPrefix("##") {
                    // Save previous section
                    if let section = currentSection {
                        saveSection(section, lines: docLines, to: &summary, &details, &usageExamples, &notes)
                    }
                    currentSection = line.trimmingPrefix("##").trimmingCharacters(in: .whitespaces)
                    docLines = []
                } else if !line.isEmpty {
                    docLines.append(line)
                }
            }
        }
        
        // Save last section
        if let section = currentSection {
            saveSection(section, lines: docLines, to: &summary, &details, &usageExamples, &notes)
        } else if !docLines.isEmpty {
            // No sections, treat as summary
            summary = docLines.joined(separator: " ")
        }
        
        return Documentation(
            summary: summary,
            details: details,
            usageExamples: usageExamples,
            notes: notes
        )
    }
    
    private static func saveSection(
        _ section: String,
        lines: [String],
        to summary: inout String?,
        _ details: inout String?,
        _ usageExamples: inout [String],
        _ notes: inout [String]
    ) {
        let content = lines.joined(separator: "\n")
        
        switch section.lowercased() {
        case "usage", "example", "examples":
            usageExamples.append(content)
        case "note", "notes", "important", "warning":
            notes.append(content)
        case "details", "description":
            details = content
        default:
            break
        }
    }
}
