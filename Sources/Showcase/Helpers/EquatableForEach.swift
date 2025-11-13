// EquatableForEach.swift
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

import SwiftUI

struct EquatableForEach<Data: RandomAccessCollection, ID: Hashable, Content: View & Equatable>: View {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let content: (_ data: Data.Element) -> Content

    /// Initializes the view with code block data.
    /// - Parameter data: The code block data.
    init?(
        data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder content: @escaping (_ data: Data.Element) -> Content
    ) {
        if data.isEmpty { return nil }
        self.data = data
        self.id = id
        self.content = content
    }

    /// The body view for displaying code blocks.
    var body: some View {
        ForEach(data, id: id) {
            content($0).equatable()
        }
    }
}
