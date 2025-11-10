// DocCommentParser.swift
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

/// Parses Swift documentation comments into structured data.
enum DocCommentParser {
    private enum Section {
        case summary, discussion, parameters, returns, `throws`, note, warning, important
    }

    private struct ParsingState {
        var summary: String?
        var discussionLines: [String] = []
        var contentParts: [ContentPart] = [] // Pre-populated from AttributedString, not modified during parsing
        var parameters: [String: String] = [:]
        var returns: String?
        var throwsInfo: String?
        var notes: [String] = []
        var warnings: [String] = []
        var important: [String] = []
        var currentSection: Section = .summary
        var currentParam: String?
        var currentParamLines: [String] = []
    }

    /// Parses a raw doc comment string into structured DocComment.
    static func parse(_ rawComment: String?) -> DocComment {
        guard let raw = rawComment else {
            return emptyDocComment()
        }

        // First, use AttributedString to extract interleaved content parts (text + code blocks)
        // This gives us robust code block parsing via PresentationIntent
        let contentParts = AttributedStringDocCommentParser.extractContentParts(from: raw)

        // Then parse the text parts for Swift doc comment sections
        let lines = raw.components(separatedBy: .newlines)
        var state = ParsingState()

        // Pre-populate content parts from AttributedString parsing
        state.contentParts = contentParts

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            parseLine(trimmed, state: &state)
        }

        return buildDocComment(from: state)
    }

    // MARK: - Parsing Helpers

    private static func parseLine(_ line: String, state: inout ParsingState) {
        // Skip code block markers since AttributedString handles code blocks
        if line.hasPrefix("```") {
            return
        }
        
        // Check for section markers first
        if let newSection = detectSectionMarker(line, state: &state) {
            state.currentSection = newSection
            return
        }

        // Handle nested parameters
        if state.currentSection == .parameters, line.hasPrefix("- ") {
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

    // NOTE: flushCurrentText is no longer needed - contentParts is pre-populated from AttributedString

    private static func handleEmptyLine(state: inout ParsingState) {
        if state.currentSection == .summary, state.summary != nil {
            state.currentSection = .discussion
        }
    }

    private static func appendToCurrentSection(_ line: String, state: inout ParsingState) {
        switch state.currentSection {
        case .summary:
            appendToSummary(line, state: &state)
        case .discussion:
            // Just extract discussion - don't add to currentTextLines (contentParts already complete)
            state.discussionLines.append(line)
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
        // Just extract summary - don't add to currentTextLines (contentParts already complete)
        if state.summary == nil {
            state.summary = line
        } else {
            state.summary! += " " + line
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

        // Clean Swift doc comment sections from text parts in contentParts
        // AttributedString doesn't understand Swift syntax (- Parameter, - Returns, etc.)
        // so we need to strip those lines from the text parts
        let cleanedContentParts = finalState.contentParts.compactMap { part -> ContentPart? in
            guard case .text(let text) = part else {
                return part // Keep code blocks as-is
            }

            // Filter out Swift doc comment section markers
            let lines = text.components(separatedBy: .newlines)
            let filteredLines = lines.filter { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                // Remove lines that are Swift doc comment sections (with or without "- " prefix)
                return !trimmed.hasPrefix("- Parameter") &&
                       !trimmed.hasPrefix("- Returns") &&
                       !trimmed.hasPrefix("- Throws") &&
                       !trimmed.hasPrefix("- Note") &&
                       !trimmed.hasPrefix("- Warning") &&
                       !trimmed.hasPrefix("- Important") &&
                       !trimmed.hasPrefix("Parameter") && // Sometimes "- " is stripped by parser
                       !trimmed.hasPrefix("Returns:") &&
                       !trimmed.hasPrefix("Throws:") &&
                       !trimmed.hasPrefix("Note:") &&
                       !trimmed.hasPrefix("Warning:") &&
                       !trimmed.hasPrefix("Important:")
            }

            let cleaned = filteredLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            return cleaned.isEmpty ? nil : .text(cleaned)
        }

        let discussion = finalState.discussionLines.isEmpty ? nil : finalState.discussionLines.joined(separator: " ")

        return DocComment(
            summary: finalState.summary,
            discussion: discussion,
            contentParts: cleanedContentParts,
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
