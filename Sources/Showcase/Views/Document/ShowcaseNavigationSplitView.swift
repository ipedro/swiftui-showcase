// ShowcaseNavigationSplitView.swift
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

/// A view that displays a list of showcases organized into chapters in a split view layout.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct ShowcaseNavigationSplitView<Sidebar: View, ContentToolbar: View, DetailToolbar: View>: View {
    // MARK: - Properties

    private let data: Document
    private let _sidebar: Sidebar
    private let contentToolbar: ContentToolbar
    private let detailToolbar: DetailToolbar

    @Binding var columnVisibility: NavigationSplitViewVisibility
    @State private var searchQuery = String()
    @State private var selection: Topic?

    // MARK: - Initialization

    /// Creates a two or three-column split view layout for showcase documentation.
    public init(
        _ data: Document,
        columnVisibility: Binding<NavigationSplitViewVisibility> = .constant(.automatic),
        @ViewBuilder sidebar: () -> Sidebar = EmptyView.init,
        @ViewBuilder contentToolbar: () -> ContentToolbar = EmptyView.init,
        @ViewBuilder detailToolbar: () -> DetailToolbar = EmptyView.init
    ) {
        self.data = data
        _columnVisibility = columnVisibility
        _sidebar = sidebar()
        self.contentToolbar = contentToolbar()
        self.detailToolbar = detailToolbar()
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if Sidebar.self != EmptyView.self {
                // Three-column layout with custom sidebar
                NavigationSplitView(
                    columnVisibility: $columnVisibility,
                    sidebar: { _sidebar },
                    content: { contentColumn },
                    detail: detailColumn
                )
            } else {
                // Two-column layout
                NavigationSplitView(
                    columnVisibility: $columnVisibility,
                    sidebar: { contentColumn },
                    detail: detailColumn
                )
            }
        }
        .previewDisplayName(data.title)
    }

    // MARK: - Content Column (List)

    private var contentColumn: some View {
        List(selection: $selection) {
            DescriptionView(data.description)
            ShowcaseChapters(
                searchQuery: $searchQuery,
                data: data.chapters
            )
        }
        .multilineTextAlignment(.leading)
        .searchable(text: $searchQuery)
        .navigationTitle(data.title)
        .toolbar {
            contentToolbar
        }
    }

    // MARK: - Detail Column

    @ViewBuilder
    private func detailColumn() -> some View {
        if let selection {
            // Use ShowcaseNavigationTopic which handles its own toolbar
            ShowcaseNavigationTopic(selection)
                .environment(\.isInSplitView, true)
                .toolbar {
                    detailToolbar
                }
        } else {
            // Empty state
            emptyDetailState
        }
    }

    private var emptyDetailState: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Select a Topic")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Choose a topic from the list to view its documentation")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .toolbar {
            detailToolbar
        }
    }
}
