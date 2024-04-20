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

extension ShowcaseCodeBlockStyle where Self == DefaultShowcaseCodeBlockStyle<BackgroundStyle> {
    /// The default style for code boxes.
    public static var automatic: Self {
        DefaultShowcaseCodeBlockStyle(
            wordWrap: false,
            background: .background,
            theme: nil
        )
    }

    public static var wordWrap: Self {
        DefaultShowcaseCodeBlockStyle(
            wordWrap: true,
            background: .background,
            theme: nil
        )
    }

    /// The default style for code boxes with a custom color theme.
    public static func automatic(
        wordWrap: Bool = false,
        theme: ((_ colorScheme: ColorScheme) -> Splash.Theme)? = nil
    ) -> Self {
        DefaultShowcaseCodeBlockStyle(
            wordWrap: wordWrap,
            background: .background,
            theme: theme
        )
    }

    @available(iOS 16, *)
    public static func automatic<S: ShapeStyle>(
        wordWrap: Bool = false,
        background: S,
        theme: ((_ colorScheme: ColorScheme) -> Splash.Theme)? = nil
    ) -> DefaultShowcaseCodeBlockStyle<S> {
        DefaultShowcaseCodeBlockStyle(
            wordWrap: wordWrap,
            background: background,
            theme: theme
        )
    }
}

/// The default style for code boxes.
public struct DefaultShowcaseCodeBlockStyle<S: ShapeStyle>: ShowcaseCodeBlockStyle {
    var wordWrap: Bool
    var background: S
    var theme: ((ColorScheme) -> Splash.Theme)?

    @Environment(\.dynamicTypeSize)
    private var typeSize

    public func makeBody(configuration: Configuration) -> some View {
        GroupBox(
            content: {
                ScrollView(wordWrap ? .vertical : .horizontal) {
                    configuration.code.frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding(
                        configuration.title == nil ? .bottom : .vertical
                    )
                }
                .fixedSize(horizontal: false, vertical: true)
                .ios16_scrollBounceBehaviorBasedOnSize(
                    axes: [.horizontal, .vertical]
                )
            },
            label: {
                HStack {
                    configuration.title
                    Spacer()
                    configuration.copyToPasteboard
                }
            }
        )
        .ios16_backgroundStyle(background)
    }

    private var font: Splash.Font {
        switch typeSize {
        case .xSmall:         Font(size: 9)
        case .small:          Font(size: 11)
        case .medium:         Font(size: 13)
        case .large:          Font(size: 15)
        case .xLarge:         Font(size: 17)
        case .xxLarge:        Font(size: 19)
        case .xxxLarge:       Font(size: 21)
        case .accessibility1: Font(size: 25)
        case .accessibility2: Font(size: 29)
        case .accessibility3: Font(size: 33)
        case .accessibility4: Font(size: 37)
        case .accessibility5: Font(size: 41)
        @unknown default:     Font(size: 17)
        }
    }

    public func makeTheme(colorScheme: ColorScheme) -> Splash.Theme {
        if let theme = theme?(colorScheme) { return theme }

        return switch colorScheme {
        case .dark: .sundellsColors(withFont: font)
        default:    .presentation(withFont: font)
        }
    }
}


#Preview {
    ShowcaseCodeBlock(
        Topic.CodeBlock("Example", text: {
"""
GroupBox(
    content: {
        configuration.code.frame(maxWidth: .infinity, alignment: .leading)
        .padding(
            configuration.title == nil ? .bottom : .vertical
        )
    },
    label: {
        HStack {
            configuration.title
            Spacer()
            configuration.copyToPasteboard
        }
    }
)
"""
        }))
    .showcaseCodeBlockStyle(.automatic(wordWrap: true))
}

#Preview {
    ShowcaseCodeBlock(
        Topic.CodeBlock(text: {
"""
HStack {
    Spacer()
    copyButton
}
"""
        }))
    .showcaseCodeBlockStyle(.automatic)
}
