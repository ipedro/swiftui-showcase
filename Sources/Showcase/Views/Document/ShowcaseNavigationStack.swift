// ShowcaseNavigationStack.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11.09.23.
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
public struct ShowcaseNavigationStack: View {
    /// The data representing showcase chapters.
    private let data: Document

    @State
    private var searchQuery = String()

    /// Initializes a showcase list with the specified data and optional icon.
    /// - Parameters:
    ///   - document: The document representing showcase chapters.
    public init(_ document: Document) {
        data = document
    }

    public var body: some View {
        NavigationStack {
            List {
                DescriptionView(data.description)
                ShowcaseChapters(
                    searchQuery: $searchQuery,
                    data: data.chapters
                )
            }
            .navigationDestination(
                for: Topic.self,
                destination: ShowcaseNavigationTopic.init
            )
            .searchable(text: $searchQuery)
            .navigationTitle(data.title)
        }
        .previewDisplayName(data.title)
    }
}

struct ShowcaseList_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseNavigationStack(
            Document(
                "My Document",
                description: "This document contains one chapter. That chapter has topics that you can find below.",
                Chapter(
                    "Components",
                    description: "This chapter is about example components",
                    Topic("Topic", previews: {
                        Button("Topic") {}
                    })
                )
            )
        )
        // .showcasePreviewStyle(.groupBoxPage)
        .showcaseCodeBlockWordWrap(true)
    }
}
