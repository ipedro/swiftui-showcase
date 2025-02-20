// ShowcaseContent.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 16.09.23.
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

@StyledView
public struct ShowcaseContent: StyledView {
    public let id: AnyHashable
    public let isEmpty: Bool
    public let title: Optional<Text>
    public let description: Optional<Text>
    public let previews: Optional<ShowcasePreviews>
    public let links: Optional<ShowcaseLinks>
    public let embeds: Optional<ShowcaseEmbeds>
    public let codeBlocks: Optional<ShowcaseCodeBlocks>

    @Environment(\.nodeDepth)
    private var depth

    @Environment(\.contentTitleFont)
    private var preferredTitleFont

    @Environment(\.contentBodyFont)
    private var preferredBodyFont

    public var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            HStack(alignment: .firstTextBaseline) {
                title.font(preferredTitleFont ?? titleStyle(depth: depth))
                if depth > 0 {
                    ShowcaseScrollTopButton()
                }
            }

            if let links = links {
                LazyHStack {
                    links
                }
            }

            description
            previews
            embeds
            codeBlocks
        }
        .transformEnvironment(\.font) { font in
            if let preferredBodyFont {
                font = preferredBodyFont
            }
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
