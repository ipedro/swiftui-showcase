// ShowcaseExampleTabStyle.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/8/25.
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

#if canImport(UIKit)

    // MARK: - Styles

    public typealias PageShowcaseExampleStyle = ShowcaseExampleTabStyle<PageTabViewStyle, TabView<Int, AnyView?>>

    public extension ShowcaseExampleStyle where Self == PageShowcaseExampleStyle {
        /// Shows the preview content in a paged scrolling `TabView`.
        static var page: PageShowcaseExampleStyle {
            ShowcaseExampleTabStyle(style: .page) { _, tabView in
                tabView
            }
        }
    }

    public typealias GroupBoxPageShowcaseExampleStyle = ShowcaseExampleTabStyle<PageTabViewStyle, GroupBox<Text?, TabView<Int, AnyView?>>>

    public extension ShowcaseExampleStyle where Self == GroupBoxPageShowcaseExampleStyle {
        /// Shows the preview content in a paged scrolling `TabView` inside a group box, with an optional title.
        static var groupBoxPage: GroupBoxPageShowcaseExampleStyle {
            ShowcaseExampleTabStyle(style: .page(indexDisplayMode: .always)) { title, tabView in
                GroupBox(label: title) {
                    tabView
                }
            }
        }
    }

    public extension ShowcaseExampleStyle where Self == ShowcaseExampleTabStyle<DefaultTabViewStyle, AnyView> {
        /// A `TabViewStyle` that implements a paged scrolling `TabView` with an
        /// index display mode.
        static func page<C: View>(
            indexDisplayMode: PageTabViewStyle.IndexDisplayMode = .automatic,
            @ViewBuilder body: @escaping (_ title: Text?, _ tabView: TabView<Int, AnyView?>) -> C
        ) -> ShowcaseExampleTabStyle<PageTabViewStyle, C> {
            ShowcaseExampleTabStyle(
                style: .page(indexDisplayMode: indexDisplayMode),
                body: body
            )
        }
    }

    public struct ShowcaseExampleTabStyle<S: TabViewStyle, C: View>: ShowcaseExampleStyle {
        /// The tab style.
        var style: S
        var body: (Text?, TabView<Int, AnyView?>) -> C

        public func makeBody(configuration: ShowcaseExampleConfiguration) -> some View {
            body(
                configuration.label,
                TabView { configuration.content }
            )
            .frame(
                maxWidth: .infinity,
                minHeight: 200
            )
            .tabViewStyle(style)
        }
    }
#endif
