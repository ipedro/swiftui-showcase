// ShowcaseIndexList.swift
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

import Engine
import EngineMacros
import SwiftUI

public extension View {
    /// Sets the style for `ShowcaseDocument` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for `ShowcaseDocument` instances
    /// within a view:
    ///
    ///     ShowcaseNavigationStack()
    ///         .showcaseIndexListStyle(MyCustomStyle())
    ///
    /// - Parameter style: Any index list style.
    /// - Returns: A view that has the index list style set in its environment.
    func showcaseIndexListStyle<S: ShowcaseIndexListStyle>(_ style: S) -> some View {
        modifier(ShowcaseIndexListStyleModifier(style))
    }
}

@StyledView
public struct ShowcaseIndexList: StyledView {
    // swiftformat:disable all
    // swiftlint:disable:next syntactic_sugar
    let data: Array<Topic>
    // swiftformat:enable all

    public var body: some View {
        EquatableForEach(
            data: data,
            id: \.title,
            content: ShowcaseIndexItem.init(data:)
        )
    }
}

struct ShowcaseIndexItem: View, Equatable {
    static func == (lhs: ShowcaseIndexItem, rhs: ShowcaseIndexItem) -> Bool {
        lhs.data.id == rhs.data.id
    }

    @Environment(\.scrollViewSelection)
    private var selection

    #if canImport(UIKit)
        @State private var impact: UISelectionFeedbackGenerator = {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            return generator
        }()
    #endif

    let data: Topic

    var body: some View {
        Button {
            #if canImport(UIKit)
                impact.prepare() // Prepare for next interaction
                impact.selectionChanged()
            #endif
            selection?.wrappedValue = data.id
        } label: {
            HStack(alignment: .top) {
                Circle()
                    .foregroundStyle(.tertiary)
                    .padding(.top, 6)
                    .frame(width: 8)
                Text(data.title)
                Spacer()
            }
            .padding(.leading, 16)
        }
        .accessibilityAddTraits(.isLink)
        .buttonStyle(_ButtonStyle())
    }

    private struct _ButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.5 : 1)
                .animation(.interactiveSpring, value: configuration.isPressed)
        }
    }
}
