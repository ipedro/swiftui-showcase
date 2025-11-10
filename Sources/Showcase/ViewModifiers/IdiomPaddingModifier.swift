//  Copyright (c) 2025 Pedro Almeida
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
import SwiftUI

extension View {
    @_disfavoredOverload
    func padding(
        phone: EdgeInsets? = nil,
        pad: EdgeInsets? = nil,
        mac: EdgeInsets? = nil,
        tv: EdgeInsets? = nil,
        watch: EdgeInsets? = nil,
        vision: EdgeInsets? = nil,
        default: EdgeInsets = .init()
    ) -> some View {
        modifier(IdiomEdgeInsetsModifier(
            phoneInsets: phone ?? `default`,
            padInsets: pad ?? `default`,
            macInsets: mac ?? `default`,
            tvInsets: tv ?? `default`,
            watchInsets: watch ?? `default`,
            visionInsets: vision ?? `default`
        ))
    }

    @_disfavoredOverload
    func padding(
        _ edges: Edge.Set = .all,
        phone: CGFloat? = nil,
        pad: CGFloat? = nil,
        mac: CGFloat? = nil,
        tv: CGFloat? = nil,
        watch: CGFloat? = nil,
        vision: CGFloat? = nil,
        default: CGFloat? = nil
    ) -> some View {
        modifier(
            IdiomEdgesLengthModifier(
                edges: edges,
                phoneLength: phone ?? `default`,
                padLength: pad ?? `default`,
                macLength: mac ?? `default`,
                tvLength: tv ?? `default`,
                watchLength: watch ?? `default`,
                visionLength: vision ?? `default`
            )
        )
    }
}

struct IdiomEdgeInsetsModifier: UserInterfaceIdiomModifier {
    let phoneInsets: EdgeInsets
    let padInsets: EdgeInsets
    let macInsets: EdgeInsets
    let tvInsets: EdgeInsets
    let watchInsets: EdgeInsets
    let visionInsets: EdgeInsets

    func phoneBody(content: Content) -> some View {
        content.padding(phoneInsets)
    }
    func padBody(content: Content) -> some View {
        content.padding(padInsets)
    }
    func macBody(content: Content) -> some View {
        content.padding(macInsets)
    }
    func tvBody(content: Content) -> some View {
        content.padding(tvInsets)
    }
    func watchBody(content: Content) -> some View {
        content.padding(watchInsets)
    }
    func visionBody(content: Content) -> some View {
        content.padding(visionInsets)
    }
}

struct IdiomEdgesLengthModifier: UserInterfaceIdiomModifier {
    let edges: Edge.Set
    let phoneLength: CGFloat?
    let padLength: CGFloat?
    let macLength: CGFloat?
    let tvLength: CGFloat?
    let watchLength: CGFloat?
    let visionLength: CGFloat?

    func phoneBody(content: Content) -> some View {
        content.padding(edges, phoneLength)
    }
    func padBody(content: Content) -> some View {
        content.padding(edges, padLength)
    }
    func macBody(content: Content) -> some View {
        content.padding(edges, macLength)
    }
    func tvBody(content: Content) -> some View {
        content.padding(edges, tvLength)
    }
    func watchBody(content: Content) -> some View {
        content.padding(edges, watchLength)
    }
    func visionBody(content: Content) -> some View {
        content.padding(edges, visionLength)
    }
}
