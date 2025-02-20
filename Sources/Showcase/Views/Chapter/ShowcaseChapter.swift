// ShowcaseChapter.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 12.09.23.
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

struct ShowcaseChapter: View {
    var topics: [Topic]
    var title: String
    var icon: Image?
    var description: String
    @Binding var isExpanded: Bool

    var body: some View {
        if #available(iOS 17.0, macOS 14.0, *) {
            Section(
                isExpanded: $isExpanded,
                content: content,
                header: header
            )
            .safeAreaInset(edge: .bottom) {
                footer().foregroundStyle(.secondary).font(.footnote)
            }
        } else {
            // Fallback on earlier versions
            Section(
                content: content,
                header: header,
                footer: footer
            )
        }
    }

    private func content() -> some View {
        OutlineGroup(topics, children: \.children) { topic in
            NavigationLink(value: topic) {
                ShowcaseChapterRow(
                    title: topic.title,
                    icon: topic.icon
                ).equatable()
            }
        }
    }

    private func header() -> some View {
        Text(title)
    }

    @ViewBuilder
    private func footer() -> some View {
        if !description.isEmpty {
            Text(description)
        }
    }
}

struct ShowcaseChapterRow: View, Equatable {
    var title: String
    var icon: Image?

    var body: some View {
        Label {
            Text(title).bold()
        } icon: {
            icon
        }
    }
}
