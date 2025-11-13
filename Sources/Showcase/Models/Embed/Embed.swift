// Embed.swift
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

import Foundation
import WebKit

public typealias EmbedNavigationHandler = (_ action: WKNavigationAction) -> WKNavigationActionPolicy

/// External content associated with a topic.
public struct Embed: Identifiable, Equatable {
    public static func == (lhs: Embed, rhs: Embed) -> Bool {
        lhs.id == rhs.id
    }

    public let id = UUID()
    public var url: URL
    public var navigationHandler: EmbedNavigationHandler
    public var isInteractionEnabled: Bool
    /// Minimum height of the preview.
    public var minHeight: CGFloat?

    public init?(
        _ url: URL?,
        minHeight: CGFloat? = nil,
        isInteractionEnabled: Bool = true,
        navigationHandler: @escaping EmbedNavigationHandler = { _ in .allow }
    ) {
        guard let url else { return nil }
        self.url = url
        self.minHeight = minHeight
        self.isInteractionEnabled = isInteractionEnabled
        self.navigationHandler = navigationHandler
    }
}
