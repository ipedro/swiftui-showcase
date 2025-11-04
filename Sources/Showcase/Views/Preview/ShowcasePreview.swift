// ShowcasePreview.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 10.09.23.
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

public struct ShowcasePreviews: View {
    var content: EquatableForEach<[Topic.Preview], Topic.Preview.ID, ShowcasePreview>
    public var body: some View { content }
}

/// A view that displays previews of showcase topics.
@StyledView
public struct ShowcasePreview: StyledView, Equatable {
    public static func == (lhs: ShowcasePreview, rhs: ShowcasePreview) -> Bool {
        lhs.id == rhs.id
    }

    init(data: Topic.Preview) {
        id = data.id
        // Create AnyView once during init - identity is stable via Equatable/id
        content = AnyView(data.content())
        label = Text(optional: data.title)
    }

    var id: UUID
    // AnyView is fine here because Equatable checks id, preventing unnecessary re-init
    var content: AnyView
    // swiftlint:disable syntactic_sugar
    var label: Optional<Text>
    // swiftlint:enable syntactic_sugar

    public var body: some View {
        content.accessibilityElement(children: .contain)
    }
}

public extension View {
    /// Sets the style for `ShowcaseDocument` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for `ShowcaseDocument` instances
    /// within a view:
    func showcasePreviewStyle<S: ShowcasePreviewStyle>(_ style: S) -> some View {
        modifier(ShowcasePreviewStyleModifier(style))
    }
}
