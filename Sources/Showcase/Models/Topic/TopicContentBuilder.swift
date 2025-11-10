// TopicContentBuilder.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/10/25.
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
import SwiftUI

/// Describes a piece of textual content that can be attached to topics or chapters.
public struct Description: View, Identifiable {
    public let id = UUID()
    public let value: String

    @inlinable
    public init(_ value: String) {
        self.value = value
    }

    /// Creates descriptive text using a closure, which is handy for
    /// multi-line string literals built with trailing-closure syntax.
    @inlinable
    public init(_ builder: () -> String) {
        value = builder()
    }

    /// Description acts as a marker in ViewBuilder contexts.
    /// Returns an empty view - the actual description is extracted by the showcase system.
    public var body: some View {
        EmptyView()
    }
}

/// A type-erased component that can contribute to a topic's content when
/// assembled through ``TopicContentBuilder``.
public protocol TopicContentConvertible {
    func merge(into content: inout Topic.Content)
}

public extension Topic {
    /// Aggregates the pieces declared inside a ``TopicContentBuilder`` into a
    /// single structure consumed by the topic initializers.
    struct Content: AdditiveArithmetic {
        /// Ordered heterogeneous content items that preserve declaration order.
        ///
        /// This array stores all content items (links, code blocks, examples, embeds)
        /// in the exact order they were declared in the builder DSL, enabling
        /// flexible content composition and rendering.
        public var items: [TopicContentItem]

        /// Child topics for hierarchical navigation.
        public var children: [Topic]

        public init(
            items: [TopicContentItem] = [],
            children: [Topic] = []
        ) {
            self.items = items
            self.children = children
        }

        // MARK: - AdditiveArithmetic

        public static var zero: Topic.Content {
            Topic.Content()
        }

        public static func + (lhs: Topic.Content, rhs: Topic.Content) -> Topic.Content {
            var result = lhs

            if !rhs.items.isEmpty {
                result.items.append(contentsOf: rhs.items)
            }

            if !rhs.children.isEmpty {
                result.children.append(contentsOf: rhs.children)
            }

            return result
        }

        public static func - (lhs: Topic.Content, rhs: Topic.Content) -> Topic.Content {
            // Subtraction doesn't make semantic sense for content, so just return lhs
            lhs
        }
    }
}

/// A result builder that assembles ``Topic.Content`` from typed DSL components.
@resultBuilder
public enum TopicContentBuilder {
    public static func buildBlock(_ components: Topic.Content...) -> Topic.Content {
        components.reduce(.zero, +)
    }

    public static func buildOptional(_ component: Topic.Content?) -> Topic.Content {
        component ?? .zero
    }

    public static func buildEither(first component: Topic.Content) -> Topic.Content {
        component
    }

    public static func buildEither(second component: Topic.Content) -> Topic.Content {
        component
    }

    public static func buildArray(_ components: [Topic.Content]) -> Topic.Content {
        components.reduce(.zero, +)
    }

    public static func buildExpression(_ expression: Topic.Content) -> Topic.Content {
        expression
    }

    public static func buildExpression(_ expression: TopicContentConvertible) -> Topic.Content {
        var content = Topic.Content()
        expression.merge(into: &content)
        return content
    }

    public static func buildExpression<Content: View>(_ content: Content) -> Topic.Content {
        var result = Topic.Content()
        let example = Example(example: content)
        result.items.append(.example(example))
        return result
    }

    public static func buildExpression(_ expression: [TopicContentConvertible]) -> Topic.Content {
        expression.reduce(into: Topic.Content()) { partialResult, element in
            element.merge(into: &partialResult)
        }
    }

    public static func buildLimitedAvailability(_ component: Topic.Content) -> Topic.Content {
        component
    }
}

extension Description: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        // Extract code blocks and lists from markdown and split into items
        let parts = extractMarkdownBlocks(from: value)
        for part in parts {
            content.items.append(part)
        }
    }

    /// Extracts markdown code blocks and lists using AttributedString's built-in parsing.
    private func extractMarkdownBlocks(from text: String) -> [TopicContentItem] {
        // First extract notes from blockquotes and special patterns
        let (textWithoutNotes, extractedNotes) = extractNotes(from: text)

        // Then extract code blocks with regex (they need raw text)
        let codePattern = "```[a-z]*\\n([\\s\\S]*?)```"
        guard let codeRegex = try? NSRegularExpression(pattern: codePattern, options: []) else {
            var allItems = extractedNotes
            allItems.append(contentsOf: parseListsFromMarkdown(textWithoutNotes))
            return allItems.isEmpty ? [.description(self)] : allItems
        }

        let nsString = textWithoutNotes as NSString
        let codeMatches = codeRegex.matches(in: textWithoutNotes, range: NSRange(location: 0, length: nsString.length))

        if codeMatches.isEmpty {
            // No code blocks, combine notes and lists
            var allItems = extractedNotes
            allItems.append(contentsOf: parseListsFromMarkdown(textWithoutNotes))
            return allItems.isEmpty ? [.description(self)] : allItems
        }

        // Process text with code blocks
        var items = extractedNotes
        var currentIndex = 0

        for match in codeMatches {
            let matchRange = match.range

            // Parse text before code block for lists
            if currentIndex < matchRange.location {
                let textRange = NSRange(location: currentIndex, length: matchRange.location - currentIndex)
                let textBefore = nsString.substring(with: textRange)
                items.append(contentsOf: parseListsFromMarkdown(textBefore))
            }

            // Add code block
            if match.numberOfRanges > 1 {
                let codeRange = match.range(at: 1)
                let code = nsString.substring(with: codeRange)
                let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)

                if !trimmed.isEmpty {
                    items.append(.codeBlock(CodeBlock(text: { trimmed })))
                }
            }

            currentIndex = matchRange.location + matchRange.length
        }

        // Parse remaining text after last code block
        if currentIndex < nsString.length {
            let textRange = NSRange(location: currentIndex, length: nsString.length - currentIndex)
            let textAfter = nsString.substring(with: textRange)
            items.append(contentsOf: parseListsFromMarkdown(textAfter))
        }

        return items.isEmpty ? [.description(self)] : items
    }

    /// Extracts notes from markdown text using blockquote or list patterns.
    /// Supports: `> Note: text`, `> Warning: text`, `- Important: text`
    private func extractNotes(from text: String) -> (String, [TopicContentItem]) {
        var extractedNotes: [TopicContentItem] = []
        var processedLines: [String] = []

        let lines = text.components(separatedBy: .newlines)

        // Pattern matches lines that start with > or - followed by Type: (without asterisks)
        let notePattern = "^[\\s]*[>-][\\s]*(Note|Important|Warning|Deprecated|Experimental|Tip):?[\\s]*(.+)$"

        guard let regex = try? NSRegularExpression(pattern: notePattern, options: []) else {
            return (text, [])
        }

        for line in lines {
            let nsLine = line as NSString
            let matches = regex.matches(in: line, range: NSRange(location: 0, length: nsLine.length))

            if let match = matches.first, match.numberOfRanges == 3 {
                // This is a note line
                let typeRange = match.range(at: 1)
                let contentRange = match.range(at: 2)

                let typeString = nsLine.substring(with: typeRange)
                let contentString = nsLine.substring(with: contentRange)
                    .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

                // Map string to NoteType
                if let noteType = Note.NoteType(rawValue: typeString) {
                    let note = Note(noteType) { contentString }
                    extractedNotes.append(.note(note))
                    // Don't add this line to processed lines
                    continue
                }
            }

            // Not a note line, keep it
            processedLines.append(line)
        }

        let remainingText = processedLines.joined(separator: "\n")
        return (remainingText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), extractedNotes)
    }

    /// Parses lists from markdown text using AttributedString's PresentationIntent.
    private func parseListsFromMarkdown(_ text: String) -> [TopicContentItem] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        // Parse markdown into AttributedString to get PresentationIntent
        guard let attributed = try? AttributedString(markdown: trimmed) else {
            return [.description(Description(trimmed))]
        }

        var items: [TopicContentItem] = []
        var listState = ListParsingState()
        var textState = TextParsingState()

        // Process each run to detect lists vs regular text
        for run in attributed.runs {
            let content = reconstructMarkdown(from: attributed, in: run.range)

            guard let intent = run.presentationIntent else {
                flushList(from: &listState, to: &items)
                textState.currentText += content
                textState.previousBlockId = nil
                continue
            }

            let blockId = intent.components.first?.identity

            if let listInfo = extractListInfo(from: intent) {
                processListRun(
                    listInfo: listInfo,
                    content: content,
                    blockId: blockId,
                    listState: &listState,
                    textState: &textState,
                    items: &items
                )
            } else {
                processNonListRun(
                    intent: intent,
                    content: content,
                    blockId: blockId,
                    listState: &listState,
                    textState: &textState,
                    items: &items
                )
            }
        }

        // Flush any remaining content
        flushList(from: &listState, to: &items)
        if !textState.currentText.isEmpty {
            items.append(.description(Description(textState.currentText)))
        }

        return items
    }

    private struct ListParsingState {
        var currentListItems: [Int: String] = [:]
        var currentListType: ListItem.ListType?
        var currentListId: Int?
        var listItemOrder: [Int] = []
    }

    private struct TextParsingState {
        var currentText = ""
        var previousBlockId: Int?
    }

    private func processListRun(
        listInfo: (listId: Int, listItemId: Int, type: ListItem.ListType),
        content: String,
        blockId: Int?,
        listState: inout ListParsingState,
        textState: inout TextParsingState,
        items: inout [TopicContentItem]
    ) {
        // Flush any text being built
        if !textState.currentText.isEmpty {
            items.append(.description(Description(textState.currentText)))
            textState.currentText = ""
        }

        // Check if this is the same list or a new list
        if listState.currentListId != listInfo.listId || listState.currentListType != listInfo.type {
            flushList(from: &listState, to: &items)
            listState.currentListType = listInfo.type
            listState.currentListId = listInfo.listId
        }

        // Accumulate content for this list item
        if listState.currentListItems[listInfo.listItemId] == nil {
            listState.listItemOrder.append(listInfo.listItemId)
            listState.currentListItems[listInfo.listItemId] = content
        } else {
            listState.currentListItems[listInfo.listItemId]? += content
        }

        textState.previousBlockId = blockId
    }

    private func processNonListRun(
        intent: AttributeScopes.FoundationAttributes.PresentationIntentAttribute.Value,
        content: String,
        blockId: Int?,
        listState: inout ListParsingState,
        textState: inout TextParsingState,
        items: inout [TopicContentItem]
    ) {
        // Flush any current list
        flushList(from: &listState, to: &items)

        // Check for heading
        let (isHeading, headingLevel) = extractHeadingInfo(from: intent)

        // Add newlines between different blocks
        if let prevId = textState.previousBlockId,
           prevId != blockId,
           !textState.currentText.isEmpty {
            textState.currentText += "\n\n"
        }

        // Add content with heading syntax if needed
        if isHeading {
            textState.currentText += String(repeating: "#", count: headingLevel) + " " + content
        } else {
            textState.currentText += content
        }

        textState.previousBlockId = blockId
    }

    private func flushList(from state: inout ListParsingState, to items: inout [TopicContentItem]) {
        guard !state.currentListItems.isEmpty, let listType = state.currentListType else { return }

        let orderedItems = state.listItemOrder.compactMap { state.currentListItems[$0] }
        items.append(.list(ListItem(type: listType, items: orderedItems)))

        state.currentListItems = [:]
        state.listItemOrder = []
        state.currentListType = nil
        state.currentListId = nil
    }

    private func extractHeadingInfo(
        from intent: AttributeScopes.FoundationAttributes.PresentationIntentAttribute.Value
    ) -> (isHeading: Bool, level: Int) {
        for component in intent.components {
            if case let .header(level) = component.kind {
                return (true, level)
            }
        }
        return (false, 0)
    }

    /// Extracts list information from PresentationIntent.
    private func extractListInfo(from intent: AttributeScopes.FoundationAttributes.PresentationIntentAttribute.Value) -> (listId: Int, listItemId: Int, type: ListItem.ListType)? {
        var listItemId: Int?
        var listType: ListItem.ListType?
        var listId: Int?

        // PresentationIntent is a collection of intents, we need to find the list ones
        for component in intent.components {
            switch component.kind {
            case .listItem:
                listItemId = component.identity
            case .orderedList:
                listType = .ordered
                listId = component.identity
            case .unorderedList:
                listType = .unordered
                listId = component.identity
            default:
                continue
            }
        }

        // We need all three pieces of information
        if let listType, let listId, let listItemId {
            return (listId: listId, listItemId: listItemId, type: listType)
        }

        return nil
    }

    /// Reconstructs markdown text from an AttributedString run, preserving formatting.
    private func reconstructMarkdown(from attributed: AttributedString, in range: Range<AttributedString.Index>) -> String {
        let substring = attributed[range]
        let text = String(substring.characters)

        // Check for inline presentation intent (bold, italic, code)
        guard let intent = substring.inlinePresentationIntent else {
            return text
        }

        // Code takes precedence
        if intent.contains(.code) {
            return "`\(text)`"
        }

        var result = text

        // Apply bold
        if intent.contains(.stronglyEmphasized) {
            result = "**\(result)**"
        }

        // Apply italic
        if intent.contains(.emphasized) {
            result = "*\(result)*"
        }

        return result
    }
}

extension Example: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.example(self))
    }
}

extension ExampleGroup: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.exampleGroup(self))
    }
}

extension CodeBlock: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.codeBlock(self))
    }
}

extension ExternalLink: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.link(self))
    }
}

extension Optional: TopicContentConvertible where Wrapped: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        guard case let .some(wrapped) = self else {
            return
        }
        wrapped.merge(into: &content)
    }
}

extension Embed: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.embed(self))
    }
}

extension ListItem: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.list(self))
    }
}

extension Note: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.items.append(.note(self))
    }
}

extension Topic: TopicContentConvertible {
    public func merge(into content: inout Topic.Content) {
        content.children.append(self)
    }
}
