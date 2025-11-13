// ShowcaseListView.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/13/25.
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

/// A view that displays a markdown list (ordered or unordered).
public struct ShowcaseListView: View {
    let data: ListItem

    public init(data: ListItem) {
        self.data = data
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(data.items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(marker(for: index))
                        .font(.body.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(minWidth: 24, alignment: .trailing)

                    renderItem(item)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.leading, 8)
    }

    private func renderItem(_ text: String) -> Text {
        do {
            let attributed = try AttributedString(styledMarkdown: text)
            return Text(attributed)
        } catch {
            return Text(text)
        }
    }

    private func marker(for index: Int) -> String {
        switch data.type {
        case .ordered:
            "\(index + 1)."
        case .unordered:
            "•"
        }
    }
}

extension ShowcaseListView: Equatable {
    public static func == (lhs: ShowcaseListView, rhs: ShowcaseListView) -> Bool {
        lhs.data.id == rhs.data.id
    }
}

#Preview("Unordered List") {
    ShowcaseListView(
        data: ListItem(
            type: .unordered,
            items: [
                "SwiftUI provides declarative syntax",
                "Built-in support for **Dark Mode**",
                "Works across all Apple platforms",
            ]
        )
    )
    .padding()
}

#Preview("Ordered List") {
    ShowcaseListView(
        data: ListItem(
            type: .ordered,
            items: [
                "Create a new SwiftUI project",
                "Add your `View` components",
                "Run in the _Xcode_ preview or simulator",
            ]
        )
    )
    .padding()
}
