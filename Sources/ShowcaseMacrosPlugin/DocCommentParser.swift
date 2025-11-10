// DocCommentParser.swift
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

/// Parses Swift documentation comments into structured data.
enum DocCommentParser {
    private enum Section {
        case summary, discussion, parameters, returns, `throws`, note, warning, important
    }
    
    private struct ParsingState {
        var summary: String?
        var discussionLines: [String] = []
        var contentParts: [ContentPart] = []
        var currentTextLines: [String] = []
        var parameters: [String: String] = [:]
        var returns: String?
        var throwsInfo: String?
        var notes: [String] = []
        var warnings: [String] = []
        var important: [String] = []
        var codeBlocks: [String] = []
        var currentSection: Section = .summary
        var currentParam: String?
        var currentParamLines: [String] = []
        var inCodeBlock: Bool = false
        var currentCodeBlockLines: [String] = []
    }
    
    /// Parses a raw doc comment string into structured DocComment.
    static func parse(_ rawComment: String?) -> DocComment {
        guard let raw = rawComment else {
            return emptyDocComment()
        }
        
        let lines = raw.components(separatedBy: .newlines)
        var state = ParsingState()
        
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            // Pass both original and trimmed - parser will use original for code blocks
            parseLine(trimmed, originalLine: line, state: &state)
        }
        
        return buildDocComment(from: state)
    }
    
    // MARK: - Parsing Helpers
    
    private static func parseLine(_ line: String, originalLine: String, state: inout ParsingState) {
        // Check for code block markers (```swift or just ```)
        if line.hasPrefix("```") {
            if state.inCodeBlock {
                // End of code block - save any pending text first
                flushCurrentText(state: &state)
                
                // Then save the code block
                let codeBlock = state.currentCodeBlockLines.joined(separator: "\n")
                if !codeBlock.isEmpty {
                    state.codeBlocks.append(codeBlock)
                    state.contentParts.append(.codeBlock(codeBlock))
                }
                state.currentCodeBlockLines = []
                state.inCodeBlock = false
            } else {
                // Start of code block - flush any accumulated text first
                flushCurrentText(state: &state)
                state.inCodeBlock = true
            }
            return
        }
        
        // If inside code block, accumulate lines with preserved indentation
        if state.inCodeBlock {
            // Use original line to preserve indentation in code blocks
            state.currentCodeBlockLines.append(originalLine)
            return
        }
        
        // Check for section markers first
        if let newSection = detectSectionMarker(line, state: &state) {
            // Flush any accumulated text before changing sections
            flushCurrentText(state: &state)
            state.currentSection = newSection
            return
        }
        
        // Handle nested parameters
        if state.currentSection == .parameters && line.hasPrefix("- ") {
            parseNestedParameter(line, state: &state)
            return
        }
        
        // Handle empty lines
        if line.isEmpty {
            handleEmptyLine(state: &state)
            return
        }
        
        // Add content to current section
        appendToCurrentSection(line, state: &state)
    }
    
    private static func detectSectionMarker(_ line: String, state: inout ParsingState) -> Section? {
        if line.hasPrefix("- Parameter ") || line.hasPrefix("- parameter ") {
            saveCurrentParameter(state: &state)
            parseParameterMarker(line, state: &state)
            return .parameters
        } else if line.hasPrefix("- Parameters:") || line.hasPrefix("- parameters:") {
            return .parameters
        } else if line.hasPrefix("- Returns:") || line.hasPrefix("- returns:") {
            parseReturnsMarker(line, state: &state)
            return .returns
        } else if line.hasPrefix("- Throws:") || line.hasPrefix("- throws:") {
            parseThrowsMarker(line, state: &state)
            return .throws
        } else if line.hasPrefix("- Note:") || line.hasPrefix("- note:") {
            parseNoteMarker(line, state: &state)
            return .note
        } else if line.hasPrefix("- Warning:") || line.hasPrefix("- warning:") {
            parseWarningMarker(line, state: &state)
            return .warning
        } else if line.hasPrefix("- Important:") || line.hasPrefix("- important:") {
            parseImportantMarker(line, state: &state)
            return .important
        }
        return nil
    }
    
    // MARK: - Section Parsers
    
    private static func parseParameterMarker(_ line: String, state: inout ParsingState) {
        let parts = line.dropFirst("- Parameter ".count).components(separatedBy: ":")
        if parts.count >= 2 {
            state.currentParam = parts[0].trimmingCharacters(in: .whitespaces)
            let desc = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            state.currentParamLines.append(desc)
        }
    }
    
    private static func parseNestedParameter(_ line: String, state: inout ParsingState) {
        saveCurrentParameter(state: &state)
        
        let parts = line.dropFirst(2).components(separatedBy: ":")
        if parts.count >= 2 {
            state.currentParam = parts[0].trimmingCharacters(in: .whitespaces)
            let desc = parts.dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces)
            state.currentParamLines.append(desc)
        }
    }
    
    private static func parseReturnsMarker(_ line: String, state: inout ParsingState) {
        let desc = line.dropFirst("- Returns:".count).trimmingCharacters(in: .whitespaces)
        state.returns = desc.isEmpty ? nil : desc
    }
    
    private static func parseThrowsMarker(_ line: String, state: inout ParsingState) {
        let desc = line.dropFirst("- Throws:".count).trimmingCharacters(in: .whitespaces)
        state.throwsInfo = desc.isEmpty ? nil : desc
    }
    
    private static func parseNoteMarker(_ line: String, state: inout ParsingState) {
        let desc = line.dropFirst("- Note:".count).trimmingCharacters(in: .whitespaces)
        if !desc.isEmpty {
            state.notes.append(desc)
        }
    }
    
    private static func parseWarningMarker(_ line: String, state: inout ParsingState) {
        let desc = line.dropFirst("- Warning:".count).trimmingCharacters(in: .whitespaces)
        if !desc.isEmpty {
            state.warnings.append(desc)
        }
    }
    
    private static func parseImportantMarker(_ line: String, state: inout ParsingState) {
        let desc = line.dropFirst("- Important:".count).trimmingCharacters(in: .whitespaces)
        if !desc.isEmpty {
            state.important.append(desc)
        }
    }
    
    // MARK: - Content Appending
    
    private static func flushCurrentText(state: inout ParsingState) {
        // Only flush if we're in summary or discussion sections (not parameters, etc.)
        guard state.currentSection == .summary || state.currentSection == .discussion else {
            return
        }
        
        if !state.currentTextLines.isEmpty {
            let text = state.currentTextLines.joined(separator: "\n")
            state.contentParts.append(.text(text))
            state.currentTextLines = []
        }
    }
    
    private static func handleEmptyLine(state: inout ParsingState) {
        if state.currentSection == .summary && state.summary != nil {
            state.currentSection = .discussion
        }
    }
    
    private static func appendToCurrentSection(_ line: String, state: inout ParsingState) {
        switch state.currentSection {
        case .summary:
            appendToSummary(line, state: &state)
        case .discussion:
            state.discussionLines.append(line)
            state.currentTextLines.append(line)
        case .parameters:
            if state.currentParam != nil {
                state.currentParamLines.append(line)
            }
        case .returns:
            appendToReturns(line, state: &state)
        case .throws:
            appendToThrows(line, state: &state)
        case .note:
            appendToLastNote(line, state: &state)
        case .warning:
            appendToLastWarning(line, state: &state)
        case .important:
            appendToLastImportant(line, state: &state)
        }
    }
    
    private static func appendToSummary(_ line: String, state: inout ParsingState) {
        if state.summary == nil {
            state.summary = line
            state.currentTextLines.append(line)
        } else {
            state.summary! += " " + line
            state.currentTextLines.append(line)
        }
    }
    
    private static func appendToReturns(_ line: String, state: inout ParsingState) {
        if state.returns == nil {
            state.returns = line
        } else {
            state.returns! += " " + line
        }
    }
    
    private static func appendToThrows(_ line: String, state: inout ParsingState) {
        if state.throwsInfo == nil {
            state.throwsInfo = line
        } else {
            state.throwsInfo! += " " + line
        }
    }
    
    private static func appendToLastNote(_ line: String, state: inout ParsingState) {
        if !state.notes.isEmpty {
            state.notes[state.notes.count - 1] += " " + line
        }
    }
    
    private static func appendToLastWarning(_ line: String, state: inout ParsingState) {
        if !state.warnings.isEmpty {
            state.warnings[state.warnings.count - 1] += " " + line
        }
    }
    
    private static func appendToLastImportant(_ line: String, state: inout ParsingState) {
        if !state.important.isEmpty {
            state.important[state.important.count - 1] += " " + line
        }
    }
    
    // MARK: - State Management
    
    private static func saveCurrentParameter(state: inout ParsingState) {
        if let param = state.currentParam, !state.currentParamLines.isEmpty {
            state.parameters[param] = state.currentParamLines.joined(separator: " ")
            state.currentParamLines = []
        }
    }
    
    private static func buildDocComment(from state: ParsingState) -> DocComment {
        var finalState = state
        saveCurrentParameter(state: &finalState)
        
        // Flush any remaining text content
        flushCurrentText(state: &finalState)
        
        let discussion = finalState.discussionLines.isEmpty ? nil : finalState.discussionLines.joined(separator: " ")
        
        return DocComment(
            summary: finalState.summary,
            discussion: discussion,
            contentParts: finalState.contentParts,
            parameters: finalState.parameters,
            returns: finalState.returns,
            throws: finalState.throwsInfo,
            notes: finalState.notes,
            warnings: finalState.warnings,
            important: finalState.important
        )
    }
    
    private static func emptyDocComment() -> DocComment {
        DocComment(
            summary: nil,
            discussion: nil,
            contentParts: [],
            parameters: [:],
            returns: nil,
            throws: nil,
            notes: [],
            warnings: [],
            important: []
        )
    }
}
