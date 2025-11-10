// VersionedScrollBounceBehavior.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/9/25.
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
    func scrollBounceBehavior(
        _ behavior: VersionedScrollBounceBehavior.Behavior,
        axes: Axis.Set = [.vertical]
    ) -> some View {
        modifier(VersionedScrollBounceBehavior(behavior: behavior, axes: axes))
    }
}

struct VersionedScrollBounceBehavior: VersionedViewModifier {
    enum Behavior: Sendable {
        /// The automatic behavior.
        case automatic
        /// The scrollable view always bounces.
        case always
        /// The scrollable view bounces when its content is large enough to require
        /// scrolling.
        case basedOnSize

        @available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *)
        var rawValue: ScrollBounceBehavior {
            switch self {
            case .automatic: .automatic
            case .always: .always
            case .basedOnSize: .basedOnSize
            }
        }
    }

    var behavior: Behavior
    var axes: Axis.Set

    func v1Body(content: Content) -> some View {
        content
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func v5Body(content: Content) -> some View {
        content.scrollBounceBehavior(behavior.rawValue, axes: axes)
    }
}
