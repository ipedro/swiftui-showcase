// ShowcaseTopic.swift
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

import SwiftUI

public struct ShowcaseTopic: View, Equatable {
    public static func == (lhs: ShowcaseTopic, rhs: ShowcaseTopic) -> Bool {
        lhs.data.id == rhs.data.id
    }

    @Environment(\.nodeDepth)
    private var depth

    let data: Topic

    public init(_ data: Topic) {
        self.data = data
    }

    public var body: some View {
        ShowcaseLayout(makeConfiguration())
    }

    // Create configuration once, avoiding recreation on every render
    private func makeConfiguration() -> ShowcaseLayoutConfiguration {
        ShowcaseLayoutConfiguration(
            children: ShowcaseTopics(data: data.children),
            indexList: makeIndexList(),
            configuration: makeContentConfiguration()
        )
    }

    private func makeContentConfiguration() -> ShowcaseContentConfiguration {
        ShowcaseContentConfiguration(
            id: data.id,
            isEmpty: data.isEmpty,
            title: depth > 0 ? Text(data.title) : nil,
            orderedItems: OrderedItems(data.items)
        )
    }

    private var showIndexList: Bool {
        depth == 0 && data.children != nil
    }

    private func makeIndexList() -> ShowcaseIndexList? {
        if depth == 0, let children = data.children {
            ShowcaseIndexList(data: children)
        } else {
            nil
        }
    }
}
