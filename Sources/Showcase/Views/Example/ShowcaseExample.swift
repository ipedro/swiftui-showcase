// ShowcaseExample.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 10.09.23.
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

public struct ShowcaseExamples: View {
    var content: EquatableForEach<[Example], Example.ID, ShowcaseExample>
    public var body: some View { content }
}

/// A view that displays previews of showcase topics.
@StyledView
public struct ShowcaseExample: StyledView, Equatable {
    public static func == (lhs: ShowcaseExample, rhs: ShowcaseExample) -> Bool {
        lhs.id == rhs.id
    }

    init(data: Example) {
        id = data.id
        // Create AnyView once during init - identity is stable via Equatable/id
        content = AnyView(data.content())
        label = Text(optional: data.title)
        codeBlock = data.codeBlock
    }

    var id: UUID
    // AnyView is fine here because Equatable checks id, preventing unnecessary re-init
    var content: AnyView
    // swiftlint:disable syntactic_sugar
    var label: Optional<Text>
    var codeBlock: CodeBlock?
    // swiftlint:enable syntactic_sugar

    @State private var isCodeExpanded = false

    public var body: some View {
        if let codeBlock = codeBlock {
            // Integrated view: Preview + Code together
            IntegratedExampleView(
                label: label,
                content: content,
                codeBlock: codeBlock,
                isCodeExpanded: $isCodeExpanded
            )
        } else {
            // Simple preview without code
            SimpleExampleView(label: label, content: content)
        }
    }
}

// MARK: - Integrated Example View (with code)

private struct IntegratedExampleView: View {
    // swiftlint:disable syntactic_sugar
    let label: Optional<Text>
    // swiftlint:enable syntactic_sugar
    let content: AnyView
    let codeBlock: CodeBlock
    @Binding var isCodeExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title if present
            if let label = label {
                label
                    .font(.headline)
                    .padding(.bottom, 12)
            }

            VStack(spacing: 0) {
                // Preview section with label
                VStack(spacing: 0) {
                    HStack {
                        Text("Preview")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.05))

                    content
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.secondary.opacity(0.02))
                }

                // Divider
                Divider()

                // Code toggle button
                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        isCodeExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("Code")
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Image(systemName: isCodeExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.secondary.opacity(0.05))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Code section (collapsible)
                if isCodeExpanded {
                    ShowcaseCodeBlock(data: codeBlock)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Simple Example View (without code)

private struct SimpleExampleView: View {
    // swiftlint:disable syntactic_sugar
    let label: Optional<Text>
    // swiftlint:enable syntactic_sugar
    let content: AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            label
                .font(.headline)

            content
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.secondary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                )
        }
        .accessibilityElement(children: .contain)
    }
}

public extension View {
    /// Sets the style for `ShowcaseDocument` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for `ShowcaseDocument` instances
    /// within a view:
    func showcasePreviewStyle<S: ShowcaseExampleStyle>(_ style: S) -> some View {
        modifier(ShowcaseExampleStyleModifier(style))
    }
}
