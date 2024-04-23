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

public extension ShowcaseCodeBlockStyle where Self == DefaultShowcaseCodeBlockStyle {
    /// The default style for code boxes.
    static var automatic: Self {
        DefaultShowcaseCodeBlockStyle(wordWrap: false)
    }

    static var wordWrap: Self {
        DefaultShowcaseCodeBlockStyle(wordWrap: true)
    }
}

public extension View {
    func showcaseCodeBlockTheme(_ theme: ShowcaseCodeBlockTheme?) -> some View {
        environment(\.codeBlockTheme, theme)
    }
}

/// The default style for code boxes.
public struct DefaultShowcaseCodeBlockStyle: ShowcaseCodeBlockStyle {
    var wordWrap: Bool


    public func makeBody(configuration: Configuration) -> some View {
        GroupBox(
            content: {
                ScrollView(wordWrap ? .vertical : .horizontal) {
                    configuration.content.frame(
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
                .foregroundStyle(Color(configuration.theme.plainTextColor))
            }
        )
        .ios16_backgroundStyle(Color(configuration.theme.backgroundColor))
    }

    public func resolve(in colorScheme: ColorScheme) -> ShowcaseCodeBlockTheme {
        return switch colorScheme {
        case .dark: .xcodeDark
        default: .xcodeLight
        }
    }
}


#Preview {
    ShowcaseCodeBlock(
        Topic.CodeBlock("Example", text: {
"""
// test
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
}

#Preview {
    ShowcaseCodeBlock(
        Topic.CodeBlock(text: {
"""
// test
HStack {
    Spacer()
    copyButton
}
"""
        }))
    .showcaseCodeBlockStyle(.automatic)
}
