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
public struct ShowcaseDocument: View {
    /// The data representing showcase chapters.
    private let data: Document

    @State
    private var searchQuery = String()

    /// Initializes a showcase list with the specified data and optional icon.
    /// - Parameters:
    ///   - document: The document representing showcase chapters.
    public init(_ document: Document) {
        self.data = document
    }

    private var chapters: [Chapter] {
        let searchQuery = searchQuery
            .localizedLowercase
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if searchQuery.isEmpty { return data.chapters }

        return data.chapters.search(searchQuery)
    }

    public var body: some View {
        List {
            DescriptionView(data.description)
            ForEach(chapters, content: section)
        }
        .searchable(text: $searchQuery)
        .navigationTitle(data.title)
        .previewDisplayName(data.title)
    }

    func section(_ chapter: Chapter) -> some View {
        Section {
            outlineGroup(chapter)
        } header: {
            Text(chapter.title)
        } footer: {
            if let footer = chapter.description {
                Text(footer)
            }
        }
    }
    
    func outlineGroup(_ chapter: Chapter) -> some View {
        OutlineGroup(chapter.topics, children: \.children) { item in
            NavigationLink {
                ScrollableTopic(data: item)
            } label: {
                TopicListLabel(
                    data: item,
                    fallbackIcon: chapter.icon ?? data.icon
                )
            }
        }
    }
}

private struct DescriptionView: View {
    let content: String

    init?(_ content: String?) {
        guard let content else { return nil }
        self.content = content
    }

    var body: some View {
        Section {
            Text(content)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}


private struct TopicListLabel: View {
    let data: Topic
    let fallbackIcon: Image?

    var body: some View {
        Label {
            Text(data.title).bold()
        } icon: {
            if let icon = data.icon { icon }
            else { fallbackIcon }
        }
    }
}

private struct ScrollableTopic: View {
    let data: Topic

    var body: some View {
        ScrollViewReader { scroll in
            ScrollView {
                Color.clear
                    .frame(height: .zero)
                    .id("top")

                ShowcaseTopic(data)
                    .navigationTitle(data.title)
                    .toolbar {
                        ToolbarItem { ShowcaseIndexMenu(data) }
                    }
            }
            .scrollViewProxy(scroll)
        }
    }
}

struct ShowcaseList_Previews: PreviewProvider {
    static var elements: [Topic] = [
        .mockButton,
        .mockCard,
        .mockAccordion
    ]
    
    static var previews: some View {
        NavigationView {
            ShowcaseDocument(
                .init(
                    "Test",
                    Chapter(
                        "Chapter",
                        elements
                    )))
        }
    }
}
