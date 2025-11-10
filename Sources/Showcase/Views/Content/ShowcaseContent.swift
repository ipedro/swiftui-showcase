// ShowcaseContent.swift
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

import Engine
import EngineMacros
import SwiftUI

public extension View {
    /// Sets the style for `ShowcaseDocument` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for `ShowcaseDocument` instances
    /// within a view:
    ///
    ///     ShowcaseNavigationStack()
    ///         .showcaseContentStyle(MyCustomStyle())
    ///
    func showcaseContentStyle<S: ShowcaseContentStyle>(_ style: S) -> some View {
        modifier(ShowcaseContentStyleModifier(style))
    }

    func showcaseTitleStyle(_ title: Font? = nil) -> some View {
        environment(\.contentTitleFont, title)
    }

    func showcaseBodyStyle(_ body: Font? = nil) -> some View {
        environment(\.contentBodyFont, body)
    }
}

/// Wrapper for ordered content items to work with @StyledView macro
public struct OrderedItems {
    public let items: [TopicContentItem]

    public init(_ items: [TopicContentItem]) {
        self.items = items
    }
}

@StyledView
public struct ShowcaseContent: StyledView {
    // swiftlint:disable syntactic_sugar
    public let id: AnyHashable
    public let isEmpty: Bool
    public let title: Optional<Text>
    public let orderedItems: OrderedItems
    // swiftlint:enable syntactic_sugar

    @Environment(\.nodeDepth)
    private var depth

    @Environment(\.contentTitleFont)
    private var preferredTitleFont

    @Environment(\.contentBodyFont)
    private var preferredBodyFont

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                title.font(preferredTitleFont ?? titleStyle(depth: depth))
                if depth > 0 {
                    ShowcaseScrollTopButton()
                }
            }
            .padding(.bottom, title != nil ? 30 : 0)

            // Render content items with adaptive spacing
            ForEach(Array(orderedItems.items.enumerated()), id: \.element.id) { index, item in
                let previousItem = index > 0 ? orderedItems.items[index - 1] : nil
                let spacing = adaptiveSpacing(for: item, after: previousItem)

                Group {
                    switch item {
                    case let .description(description):
                        renderDescription(description.value)
                    case let .link(link):
                        ShowcaseLink(data: link)
                    case let .codeBlock(codeBlock):
                        ShowcaseCodeBlock(data: codeBlock)
                    case let .list(list):
                        ShowcaseListView(data: list)
                    case let .note(note):
                        ShowcaseNote(note: note)
                    case let .example(example):
                        ShowcaseExample(data: example)
                    case let .exampleGroup(group):
                        ShowcaseExampleGroup(examples: group.examples, title: group.title)
                    case let .embed(embed):
                        ShowcaseEmbed(data: embed)
                    }
                }
                .padding(.top, spacing)
            }
        }
        .transformEnvironment(\.font) { font in
            if let preferredBodyFont {
                font = preferredBodyFont
            }
        }
    }

    /// Calculates adaptive spacing between content items based on their types
    private func adaptiveSpacing(for item: TopicContentItem, after previous: TopicContentItem?) -> CGFloat {
        guard let previous else { return 0 }

        // Define spacing rules based on content relationships
        switch (previous, item) {
        case (.description, .codeBlock):
            return 16 // Tight: Description followed by related code
        case (.description, .list):
            return 12 // Tight: Description followed by list
        case (.description, .note):
            return 20 // Medium: Note needs some breathing room
        case (.codeBlock, .description):
            return 24 // Medium: Code block followed by explanation
        case (.codeBlock, .codeBlock):
            return 20 // Medium: Multiple code blocks
        case (.example, .example),
             (.example, .exampleGroup),
             (.exampleGroup, .example),
             (.exampleGroup, .exampleGroup):
            return 32 // Large: Maintain generous spacing for visual examples
        case (.example, .codeBlock):
            return 24 // Medium: Example followed by related code
        case (_, .example):
            return 32 // Large: Examples need space before them
        case (_, .exampleGroup):
            return 32 // Large: Example groups need space before them
        case (.note, _):
            return 24 // Medium: Space after notes
        case (_, .note):
            return 24 // Medium: Space before notes
        case (.list, .list):
            return 20 // Medium: Multiple lists
        case (.description, .description):
            return 20 // Medium: Paragraph spacing
        default:
            return 24 // Default spacing
        }
    }

    func renderDescription(_ description: String) -> Text {
        do {
            let attributedString = try AttributedString(styledMarkdown: description)
            return Text(attributedString)
        } catch {
            return Text(description)
        }
    }

    private func titleStyle(depth: Int) -> Font {
        switch depth {
        case 0: return .largeTitle
        case 1: return .title
        case 2: return .title2
        case 3: return .title3
        default: return .headline
        }
    }
}

extension ShowcaseContent: Equatable {
    public static func == (lhs: ShowcaseContent, rhs: ShowcaseContent) -> Bool {
        lhs.id == rhs.id
    }
}

struct ShowcaseScrollTopButton: View {
    @Environment(\.scrollViewSelection)
    private var selection

    #if canImport(UIKit)
        let impact = UISelectionFeedbackGenerator()
    #endif

    var body: some View {
        Button {
            #if canImport(UIKit)
                impact.selectionChanged()
            #endif
            selection?.wrappedValue = ShowcaseScrollViewTopAnchor.ID
        } label: {
            Image(systemName: "arrow.up.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.title3)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Scroll to top")
        }
    }
}

// Source - https://stackoverflow.com/a/79068263
// Posted by Joony
// Retrieved 2025-11-10, License - CC BY-SA 4.0

extension AttributedString {
    init(styledMarkdown markdownString: String) throws {
        // Ensure proper paragraph breaks before markdown headers
        // Markdown parsers can collapse whitespace, so we normalize to ensure
        // there are always TWO blank lines before headers for proper spacing
        var normalizedMarkdown = markdownString

        // Replace any occurrence of newlines before headers with double newlines
        // This handles: "\n## Header" -> "\n\n## Header"
        // And: "\n\n## Header" -> "\n\n\n## Header"
        for level in 1 ... 6 {
            let headerPrefix = String(repeating: "#", count: level)
            normalizedMarkdown = normalizedMarkdown.replacingOccurrences(
                of: "\n\(headerPrefix) ",
                with: "\n\n\(headerPrefix) ",
                options: .literal
            )
        }

        var output = try AttributedString(
            markdown: normalizedMarkdown,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            ),
            baseURL: nil
        )

        // Style inline code (backticks)
        for (inlineIntent, range) in output.runs[AttributeScopes.FoundationAttributes.InlinePresentationIntentAttribute.self] {
            guard let inlineIntent = inlineIntent, inlineIntent.contains(.code) else { continue }
            output[range].font = .system(.body, design: .monospaced)
            output[range].backgroundColor = Color.secondary.opacity(0.15)
            #if canImport(UIKit)
                output[range].foregroundColor = .label
            #elseif canImport(AppKit)
                output[range].foregroundColor = .labelColor
            #endif
        }

        // Style headers
        for (intentBlock, intentRange) in output.runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self].reversed() {
            guard let intentBlock = intentBlock else { continue }
            for intent in intentBlock.components {
                switch intent.kind {
                case let .header(level: level):
                    switch level {
                    case 1:
                        output[intentRange].font = .system(.title).bold()
                    case 2:
                        output[intentRange].font = .system(.title2).bold()
                    case 3:
                        output[intentRange].font = .system(.title3).bold()
                    default:
                        break
                    }
                default:
                    break
                }
            }

            if intentRange.lowerBound != output.startIndex {
                // Add TWO newlines (blank line) before headers for proper paragraph spacing
                output.characters.insert(contentsOf: "\n\n", at: intentRange.lowerBound)
            }
        }

        self = output
    }
}
