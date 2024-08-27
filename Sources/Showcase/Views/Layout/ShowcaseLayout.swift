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

// MARK: - View Extension

public extension View {
    /// Sets the style for Showcase within this view to a showcase layout layout style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for Showcase instances
    /// within a view:
    ///
    ///     Showcase(element)
    ///         .layoutStyle(.standard)
    ///
    /// - Parameter style: Any showcase layout style.
    /// - Returns: A view that has the showcase layout style set in its environment.
    func layoutStyle<S: ShowcaseLayoutStyle>(_ style: S) -> some View {
        modifier(ShowcaseLayoutStyleModifier(style))
    }
}

@StyledView
public struct ShowcaseLayout: StyledView {
    /// The children views within the showcase.
    public let children: Optional<ShowcaseTopics>
    /// The index view for navigating within the showcase.
    public let indexList: Optional<ShowcaseIndexList>
    /// The content view of the showcase.
    public let configuration: ShowcaseContentConfiguration

    @Environment(\.nodeDepth)
    public var depth

    public var body: some View {
        LazyVStack(alignment: .leading) {
            if depth > 0, !configuration.isEmpty {
                Divider().padding(.bottom)
            }

            // FIXME: add back after scroll fix
            // indexList?.padding(.bottom, 30)

            ShowcaseContent(configuration).equatable()
            
            children?.equatable()
        }
        .padding(depth == .zero ? .horizontal : [])
        .padding(depth == .zero ? [] : .vertical)
        .padding(configuration.isEmpty ? [] : .bottom, 20)
    }
}
