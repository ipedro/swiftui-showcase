// ShowcaseExampleGroup.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 10.11.25.
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

import SwiftUI

/// A view that groups multiple examples in a TabView for easy switching.
public struct ShowcaseExampleGroup: View {
    let examples: [Example]
    let groupTitle: String?

    @State private var selectedIndex: Int = 0

    public init(examples: [Example], title: String? = nil) {
        self.examples = examples
        groupTitle = title
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Group title if provided
            if let title = groupTitle {
                Text(title)
                    .font(.headline)
                    .padding(.bottom, 12)
            }

            VStack(spacing: 0) {
                // Tab selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(examples.enumerated()), id: \.offset) { index, example in
                            TabButton(
                                title: example.title ?? "Example \(index + 1)",
                                index: index,
                                isSelected: selectedIndex == index
                            ) {
                                withAnimation(.snappy(duration: 0.2)) {
                                    selectedIndex = index
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .background(Color.secondary.opacity(0.05))

                Divider()

                // Tab content - show selected example
                if examples.indices.contains(selectedIndex) {
                    ShowcaseExample(data: examples[selectedIndex])
                        .padding()
                        .frame(maxWidth: .infinity)
                        .transition(.opacity)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
        }
    }
}

// MARK: - Tab Button

private struct TabButton: View {
    let title: String
    let index: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    isSelected
                        ? Color.accentColor.opacity(0.15)
                        : Color.clear
                )
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            isSelected
                                ? Color.accentColor.opacity(0.3)
                                : Color.clear,
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(isSelected ? "Currently showing this example" : "Show example \(index + 1)"))
        .accessibilityValue(Text(isSelected ? "Selected" : "Not selected"))
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}
