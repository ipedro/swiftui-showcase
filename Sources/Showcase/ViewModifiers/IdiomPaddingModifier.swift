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
        phone: EdgeInsets = .init(),
        pad: EdgeInsets = .init(),
        mac: EdgeInsets = .init(),
        tv: EdgeInsets = .init(),
        watch: EdgeInsets = .init(),
        vision: EdgeInsets = .init()
    ) -> some View {
        modifier(IdiomEdgeInsetsModifier(
            phoneInsets: phone,
            padInsets: pad,
            macInsets: mac,
            tvInsets: tv,
            watchInsets: watch,
            visionInsets: vision
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
        vision: CGFloat? = nil
    ) -> some View {
        modifier(
            IdiomEdgesLengthModifier(
                edges: edges,
                phoneLength: phone,
                padLength: pad,
                macLength: mac,
                tvLength: tv,
                watchLength: watch,
                visionLength: vision
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
