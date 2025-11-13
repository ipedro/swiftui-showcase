// ShowcaseExampleGroupBoxStyle.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/08/25.
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

public extension ShowcaseExampleStyle where Self == ShowcaseExampleGroupBoxStyle<DefaultGroupBoxStyle> {
    /// Shows the preview content inside a group box, with an optional title.
    static var groupBox: ShowcaseExampleGroupBoxStyle<DefaultGroupBoxStyle> {
        ShowcaseExampleGroupBoxStyle(style: .automatic)
    }

    /// Shows the preview content inside a custom group box.
    static func groupBox<S: GroupBoxStyle>(_ style: S) -> ShowcaseExampleGroupBoxStyle<S> {
        ShowcaseExampleGroupBoxStyle(style: style)
    }
}

public struct ShowcaseExampleGroupBoxStyle<S: GroupBoxStyle>: ShowcaseExampleStyle {
    var style: S

    public func makeBody(configuration: ShowcaseExampleConfiguration) -> some View {
        GroupBox {
            configuration.content
        } label: {
            configuration.label
        }
        .groupBoxStyle(style)
    }
}
