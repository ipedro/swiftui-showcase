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
        let searchQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchQuery.count < 3 { return data.chapters }
        let result = data.chapters.search(searchQuery)
        return result
    }

    public var body: some View {
        List {
            DescriptionView(data.description)
            ForEach(chapters) {
                ShowcaseChapter(data: $0).navigationTitle($0.title)
            }
        }
        .searchable(text: $searchQuery)
        .navigationTitle(data.title)
        .previewDisplayName(data.title)
    }

}

private struct DescriptionView: View {
    let content: String

    init?(_ content: String?) {
        guard let content else { return nil }
        self.content = content
    }

    var body: some View {
        Text(content)
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.top, 5)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

struct ShowcaseList_Previews: PreviewProvider {
    static var topics: [Topic] = [
        .mockButton,
        .mockCard,
        .mockAccordion
    ]
    
    static var previews: some View {
        NavigationView {
            ShowcaseDocument(
                Document(
                    "My Document",
                    description: "This document contains one chapter. That chapter has \(topics.count) topics that you can find below.",
                    Chapter(
                        "Components",
                        description: "This chapter is about \(topics.count) components",
                        topics
                    )
                )
            )
        }
        .showcasePreviewStyle(.groupBoxPage)
        .showcaseCodeBlockStyle(.wordWrap)
    }
}
