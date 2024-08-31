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
import Engine
import EngineMacros

extension View {
    /// Sets the style for ``ShowcaseDocument`` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for ``ShowcaseDocument`` instances
    /// within a view:
    ///
    ///     ShowcaseNavigationStack()
    ///         .showcaseIndexListStyle(MyCustomStyle())
    ///
    /// - Parameter style: Any index list style.
    /// - Returns: A view that has the index list style set in its environment.
    public func showcaseIndexListStyle<S: ShowcaseIndexListStyle>(_ style: S) -> some View {
        modifier(ShowcaseIndexListStyleModifier(style))
    }
}

@StyledView
public struct ShowcaseIndexList: StyledView {
    let data: Topic

    @Environment(\.nodeDepth)
    private var depth

    public var body: some View {
        let depthPadding = CGFloat(depth) * 16
        VStack(alignment: .leading) {
            if depth > 0 {
                ShowcaseIndexItem(data: data).padding(.leading, depthPadding)
            }
            if let topics = data.children {
                ForEach(topics) { topic in
                    ShowcaseIndexList(data: topic).environment(\.nodeDepth, depth + 1)
                }
            }
        }
    }
}

struct ShowcaseIndexItem: View {
    @Environment(\.scrollViewSelection)
    private var selection

    #if canImport(UIKit)
    let impact = UIImpactFeedbackGenerator(style: .light)
    #endif

    var data: Topic

    var body: some View {
        Button {
            #if canImport(UIKit)
            impact.impactOccurred()
            #endif
            selection!.wrappedValue = data.id
        } label: {
            HStack(alignment: .top) {
                Circle()
                    .foregroundStyle(.tertiary)
                    .padding(.top, 6)
                    .frame(width: 8)
                Text(data.title)
                Spacer()
            }
        }
        .accessibilityAddTraits(.isLink)
        .buttonStyle(_ButtonStyle())
    }

    private struct _ButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
        }
    }
}
