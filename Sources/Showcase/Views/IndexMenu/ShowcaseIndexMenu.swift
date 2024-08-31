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

extension View {
    /// Sets the style for ``ShowcaseDocument`` within this view to a index menu style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for ``ShowcaseDocument`` instances
    /// within a view:
    ///
    ///     ShowcaseNavigationStack()
    ///         .showcaseIndexMenuStyle(MyCustomStyle())
    ///
    /// - Parameter style: Any index menu style
    /// - Returns: A view that has the index menu style set in its environment.
    public func showcaseIndexMenuStyle<S: ShowcaseIndexMenuStyle>(_ style: S) -> some View {
        modifier(ShowcaseIndexMenuStyleModifier(style))
    }
}

@StyledView
public struct ShowcaseIndexMenu: StyledView {
    public let label: ShowcaseIndexMenuLabel
    public let icon: ShowcaseIndexMenuIcon

    init?(_ data: Topic) {
        if data.allChildren.isEmpty { return nil }
        label = ShowcaseIndexMenuLabel(data: data)
        icon = ShowcaseIndexMenuIcon()
    }

    public var body: some View {
        Menu {
            label.equatable()
        } label: {
            icon
        }
    }
}

// MARK: - Configuration

public struct ShowcaseIndexMenuLabel: View, Equatable {
    public static func == (lhs: ShowcaseIndexMenuLabel, rhs: ShowcaseIndexMenuLabel) -> Bool {
        lhs.data == rhs.data
    }

    @Environment(\.scrollViewSelection)
    private var selection

    let data: Topic

    #if canImport(UIKit)
    let impact = UIImpactFeedbackGenerator(style: .light)
    #endif

    public var body: some View {
        button(data)

        Divider()

        let children = data.allChildren

        if !children.isEmpty {
            ForEach(children, content: button)
        }
    }

    private func button(_ data: Topic) -> some View {
        Button(data.title) {
            #if canImport(UIKit)
            impact.impactOccurred()
            #endif
            selection?.wrappedValue = data.id
        }
    }
}

public struct ShowcaseIndexMenuIcon: View {
    var systemName: String = "list.bullet"

    /// The shape used for the icon.
    private let shape = RoundedRectangle(
        cornerRadius: 8,
        style: .continuous)

    public var body: some View {
        Image(systemName: systemName)
            .padding(5)
            .mask { shape }
            .background {
                shape.opacity(0.1)
            }
    }
}
