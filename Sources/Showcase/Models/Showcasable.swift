// Showcasable.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/09/25.
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
import SwiftUI

/// A type that can provide showcase documentation.
///
/// This protocol is automatically conformed to by types marked with `@Showcasable`.
/// You typically don't need to conform to this manually.
public protocol Showcasable {
    /// The generated topic containing this type's documentation.
    static var showcaseTopic: Topic { get }
}

public extension ViewBuilder {
    static func buildExpression<T: Showcasable>(_ expression: T.Type) -> some View {
        NavigationStack {
            ScrollView {
                T.showcaseTopic
            }
        }
    }
}
