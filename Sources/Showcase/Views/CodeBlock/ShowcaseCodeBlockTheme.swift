// ShowcaseCodeBlockTheme.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 21.04.24.
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
import Splash

public struct ShowcaseCodeBlockTheme {
    /// What color to use for plain text (no highlighting)
    public var plainTextColor: Splash.Color
    /// What color to use for the background
    public var backgroundColor: Splash.Color
    /// What color to use for the text's highlighted tokens
    public var tokenColors: [Splash.TokenType: Splash.Color]

    public init(
        plainTextColor: Splash.Color,
        tokenColors: [Splash.TokenType: Splash.Color],
        backgroundColor: Splash.Color = ._defaultBackground
    ) {
        self.plainTextColor = plainTextColor
        self.tokenColors = tokenColors
        self.backgroundColor = backgroundColor
    }
}

#if os(iOS)
    import UIKit
#elseif os(macOS)
    import Cocoa
#endif

public extension Splash.Color {
    #if os(iOS)
        static var _defaultBackground: Splash.Color {
            return .systemGroupedBackground
        }

    #elseif os(macOS)
        static var _defaultBackground: Splash.Color {
            return .windowBackgroundColor
        }
    #endif
}

public extension ShowcaseCodeBlockTheme {
    static var vscodeDark: ShowcaseCodeBlockTheme {
        ShowcaseCodeBlockTheme(
            plainTextColor: Splash.Color(red: 0.8, green: 0.8, blue: 0.8, alpha: 1),
            tokenColors: [
                .keyword: Splash.Color(red: 0.854, green: 0.439, blue: 0.839, alpha: 1),
                .string: Splash.Color(red: 0.886, green: 0.655, blue: 0.222, alpha: 1),
                .type: Splash.Color(red: 0.678, green: 0.749, blue: 0.854, alpha: 1),
                .call: Splash.Color(red: 0.678, green: 0.749, blue: 0.854, alpha: 1),
                .number: Splash.Color(red: 0.686, green: 0.639, blue: 0.854, alpha: 1),
                .comment: Splash.Color(red: 0.482, green: 0.561, blue: 0.607, alpha: 1),
                .property: Splash.Color(red: 0.678, green: 0.749, blue: 0.854, alpha: 1),
                .dotAccess: Splash.Color(red: 0.678, green: 0.749, blue: 0.854, alpha: 1),
                .preprocessing: Splash.Color(red: 0.854, green: 0.439, blue: 0.839, alpha: 1)
            ],
            backgroundColor: Splash.Color(red: 0.152, green: 0.168, blue: 0.202, alpha: 1)
        )
    }

    static var sublime: ShowcaseCodeBlockTheme {
        ShowcaseCodeBlockTheme(
            plainTextColor: Splash.Color(white: 0.9, alpha: 1),
            tokenColors: [
                .keyword: Splash.Color(red: 0.992, green: 0.357, blue: 0.486, alpha: 1),
                .string: Splash.Color(red: 0.761, green: 0.845, blue: 0.247, alpha: 1),
                .type: Splash.Color(red: 0.694, green: 0.627, blue: 0.847, alpha: 1),
                .call: Splash.Color(red: 0.694, green: 0.627, blue: 0.847, alpha: 1),
                .number: Splash.Color(red: 1.0, green: 0.631, blue: 0.286, alpha: 1),
                .comment: Splash.Color(red: 0.576, green: 0.631, blue: 0.631, alpha: 1),
                .property: Splash.Color(red: 0.694, green: 0.627, blue: 0.847, alpha: 1),
                .dotAccess: Splash.Color(red: 0.694, green: 0.627, blue: 0.847, alpha: 1),
                .preprocessing: Splash.Color(red: 0.992, green: 0.357, blue: 0.486, alpha: 1)
            ],
            backgroundColor: Splash.Color(red: 0.149, green: 0.149, blue: 0.149, alpha: 1)
        )
    }

    static var classicBlue: ShowcaseCodeBlockTheme {
        ShowcaseCodeBlockTheme(
            plainTextColor: Splash.Color.black,
            tokenColors: [
                .keyword: Splash.Color(red: 0.0, green: 0.0, blue: 0.9, alpha: 1),
                .string: Splash.Color(red: 0.9, green: 0.0, blue: 0.0, alpha: 1),
                .type: Splash.Color(red: 0.275, green: 0.5, blue: 0.7, alpha: 1),
                .call: Splash.Color(red: 0.0, green: 0.5, blue: 0.0, alpha: 1),
                .number: Splash.Color(red: 0.5, green: 0.0, blue: 0.5, alpha: 1),
                .comment: Splash.Color(red: 0.4, green: 0.4, blue: 0.4, alpha: 1),
                .property: Splash.Color(red: 0.2, green: 0.2, blue: 0.7, alpha: 1),
                .dotAccess: Splash.Color(red: 0.4, green: 0.4, blue: 0.6, alpha: 1),
                .preprocessing: Splash.Color(red: 0.5, green: 0.3, blue: 0.1, alpha: 1)
            ],
            backgroundColor: ._defaultBackground
        )
    }

    static var xcodeLight: ShowcaseCodeBlockTheme {
        ShowcaseCodeBlockTheme(
            plainTextColor: Splash.Color.black,
            tokenColors: [
                .keyword: Splash.Color(red: 0.894, green: 0.0, blue: 0.447, alpha: 1),
                .string: Splash.Color(red: 0.204, green: 0.478, blue: 0.004, alpha: 1),
                .type: Splash.Color(red: 0.651, green: 0.192, blue: 0.657, alpha: 1),
                .call: Splash.Color(red: 0.0, green: 0.0, blue: 1.0, alpha: 1),
                .number: Splash.Color(red: 0.102, green: 0.102, blue: 1.0, alpha: 1),
                .comment: Splash.Color(red: 0.437, green: 0.531, blue: 0.567, alpha: 1),
                .property: Splash.Color(red: 0.651, green: 0.192, blue: 0.657, alpha: 1),
                .dotAccess: Splash.Color(red: 0.502, green: 0.0, blue: 0.502, alpha: 1),
                .preprocessing: Splash.Color(red: 0.800, green: 0.0, blue: 0.0, alpha: 1)
            ],
            backgroundColor: ._defaultBackground
        )
    }

    static var xcodeDark: ShowcaseCodeBlockTheme {
        ShowcaseCodeBlockTheme(
            plainTextColor: Splash.Color(white: 0.8, alpha: 1),
            tokenColors: [
                .keyword: Splash.Color(red: 0.886, green: 0.348, blue: 0.536, alpha: 1),
                .string: Splash.Color(red: 0.886, green: 0.680, blue: 0.364, alpha: 1),
                .type: Splash.Color(red: 0.562, green: 0.454, blue: 0.886, alpha: 1),
                .call: Splash.Color(red: 0.364, green: 0.886, blue: 0.593, alpha: 1),
                .number: Splash.Color(red: 0.886, green: 0.586, blue: 0.453, alpha: 1),
                .comment: Splash.Color(red: 0.537, green: 0.631, blue: 0.667, alpha: 1),
                .property: Splash.Color(red: 0.562, green: 0.454, blue: 0.886, alpha: 1),
                .dotAccess: Splash.Color(red: 0.562, green: 0.454, blue: 0.886, alpha: 1),
                .preprocessing: Splash.Color(red: 0.886, green: 0.348, blue: 0.536, alpha: 1)
            ],
            backgroundColor: Splash.Color(red: 0.098, green: 0.118, blue: 0.137, alpha: 1)
        )
    }

    static var githubLight: ShowcaseCodeBlockTheme {
        ShowcaseCodeBlockTheme(
            plainTextColor: Splash.Color.black,
            tokenColors: [
                .keyword: Splash.Color(red: 0.0, green: 0.0, blue: 0.9, alpha: 1),
                .string: Splash.Color(red: 0.188, green: 0.522, blue: 0.094, alpha: 1),
                .type: Splash.Color(red: 0.0, green: 0.0, blue: 0.9, alpha: 1),
                .call: Splash.Color(red: 0.0, green: 0.0, blue: 0.9, alpha: 1),
                .number: Splash.Color(red: 0.208, green: 0.149, blue: 0.736, alpha: 1),
                .comment: Splash.Color(red: 0.433, green: 0.433, blue: 0.433, alpha: 1),
                .property: Splash.Color(red: 0.0, green: 0.0, blue: 0.9, alpha: 1),
                .dotAccess: Splash.Color(red: 0.0, green: 0.0, blue: 0.9, alpha: 1),
                .preprocessing: Splash.Color(red: 0.9, green: 0.0, blue: 0.0, alpha: 1)
            ],
            backgroundColor: ._defaultBackground
        )
    }

    static var githubDark: ShowcaseCodeBlockTheme {
        ShowcaseCodeBlockTheme(
            plainTextColor: Splash.Color(white: 0.9, alpha: 1),
            tokenColors: [
                .keyword: Splash.Color(red: 0.678, green: 0.196, blue: 0.698, alpha: 1),
                .string: Splash.Color(red: 0.762, green: 0.644, blue: 0.192, alpha: 1),
                .type: Splash.Color(red: 0.678, green: 0.196, blue: 0.698, alpha: 1),
                .call: Splash.Color(red: 0.678, green: 0.196, blue: 0.698, alpha: 1),
                .number: Splash.Color(red: 0.878, green: 0.392, blue: 0.392, alpha: 1),
                .comment: Splash.Color(red: 0.498, green: 0.498, blue: 0.498, alpha: 1),
                .property: Splash.Color(red: 0.678, green: 0.196, blue: 0.698, alpha: 1),
                .dotAccess: Splash.Color(red: 0.678, green: 0.196, blue: 0.698, alpha: 1),
                .preprocessing: Splash.Color(red: 0.796, green: 0.196, blue: 0.196, alpha: 1)
            ],
            backgroundColor: Splash.Color(red: 0.1, green: 0.11, blue: 0.12, alpha: 1)
        )
    }
}
