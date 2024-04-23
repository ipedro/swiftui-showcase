// Copyright (c) 2023 Pedro Almeida
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

/// A view that displays a list of showcases organized into chapters.
@available(iOS 16.0, *)
public struct ShowcaseNavigationSplitView<Sidebar: View>: View {
    /// The data representing showcase chapters.
    private let data: Document

    private let _sidebar: Sidebar

    @State
    private var searchQuery = String()

    @Binding
    var columnVisibility: NavigationSplitViewVisibility

    @State
    private var selection: Topic?

    public init(
        _ data: Document,
        columnVisibility: Binding<NavigationSplitViewVisibility> = .constant(.automatic),
        @ViewBuilder sidebar: () -> Sidebar
    ) {
        self.data = data
        self._columnVisibility = columnVisibility
        self._sidebar = sidebar()
    }

    public var body: some View {
        NavigationSplitView(
            columnVisibility: $columnVisibility,
            sidebar: sidebar,
            content: content,
            detail: detail
        )
        .previewDisplayName(data.title)
    }

    @ViewBuilder
    private func sidebar() -> some View {
        if Sidebar.self != EmptyView.self {
            _sidebar
        } else {
            list
        }
    }

    @ViewBuilder
    private func content() -> some View {
        if Sidebar.self != EmptyView.self {
            list
        } else {
            _sidebar
        }
    }

    @ViewBuilder
    private func detail() -> some View {
        ShowcaseNavigationTopic(selection)
    }

    private var list: some View {
        List(selection: $selection) {
            DescriptionView(data.description)
            SearchableChapters(
                searchQuery: $searchQuery,
                data: data.chapters
            )
        }
        .searchable(text: $searchQuery)
        .navigationTitle(data.title)
    }
}

#Preview {
    ShowcaseNavigationSplitView(
        .systemComponents,
        columnVisibility: .constant(.automatic),
        sidebar: EmptyView.init
    )
}
