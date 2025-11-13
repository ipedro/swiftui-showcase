// ShowcaseIndexMenu.swift
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

import Engine
import EngineMacros
import SwiftUI

// MARK: - View Extension

public extension View {
    /// Sets the style for `ShowcaseDocument` within this view to a index menu style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for `ShowcaseDocument` instances
    /// within a view:
    ///
    ///     ShowcaseNavigationStack()
    ///         .showcaseIndexMenuStyle(MyCustomStyle())
    ///
    /// - Parameter style: Any index menu style
    /// - Returns: A view that has the index menu style set in its environment.
    func showcaseIndexMenuStyle<S: ShowcaseIndexMenuStyle>(_ style: S) -> some View {
        modifier(ShowcaseIndexMenuStyleModifier(style))
    }
}

@StyledView
public struct ShowcaseIndexMenu: StyledView {
    @Environment(\.scrollViewSelection)
    private var selection

    var title: String = ""
    var data: [Topic] = []

    init(_ topic: Topic) {
        title = topic.title
        data = topic.children ?? []
    }

    public var body: some View {
        if !data.isEmpty {
            Menu {
                // Scroll to top button
                Button(title) {
                    selection?.wrappedValue = ShowcaseScrollViewTopAnchor.ID
                }

                Divider()

                // Child topic buttons
                ForEach(data, id: \.id) { topic in
                    Button(topic.title) {
                        selection?.wrappedValue = topic.id
                    }
                }
            } label: {
                ShowcaseIndexMenuIcon()
            }
        }
    }
}

// MARK: - Icon

public struct ShowcaseIndexMenuIcon: View {
    var systemName: String = "list.bullet"

    /// The shape used for the icon.
    private let shape = RoundedRectangle(
        cornerRadius: 8,
        style: .continuous
    )

    public var body: some View {
        Image(systemName: systemName)
            .padding(5)
            .mask { shape }
            .background {
                shape.opacity(0.1)
            }
    }
}

#Preview("Index Menu") {
    ShowcaseIndexMenu(
        Topic("SwiftUI Basics") {
            Topic("Text") {
                Description("Display and style text")
            }
            Topic("Image") {
                Description("Show images and icons")
            }
            Topic("Button") {
                Description("Handle user interactions")
            }
        }
    )
}

#Preview("Menu Icon") {
    HStack(spacing: 20) {
        ShowcaseIndexMenuIcon()
        ShowcaseIndexMenuIcon(systemName: "book")
        ShowcaseIndexMenuIcon(systemName: "star")
    }
    .padding()
}
