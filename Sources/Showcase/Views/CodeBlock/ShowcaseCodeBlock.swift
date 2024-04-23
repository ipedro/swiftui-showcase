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
import Splash
#if os(iOS)
import UIKit
#endif

/// A view that displays code blocks with syntax highlighting and a copy to pasteboard button.
struct ShowcaseCodeBlock: View {
    typealias Configuration = ShowcaseCodeBlockStyleConfiguration
    @Environment(\.codeBlockStyle)
    private var style

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.codeBlockTheme)
    private var theme

    var data: Topic.CodeBlock

    /// Initializes a ShowcaseCodeBlock view with the specified code block data.
    /// - Parameter data: The data representing the code block (optional).
    init?(_ data: Topic.CodeBlock?) {
        guard let data = data else { return nil }
        self.data = data
    }

    var configuration: Configuration {
        Configuration(
            title: Text(optional: LocalizedStringKey(optional: data.title)),
            rawValue: data.rawValue,
            theme: theme ?? style.resolve(in: colorScheme)
        )
    }

    var body: some View {
        AnyView(style.resolve(configuration: configuration))
    }
}

public struct ShowcaseCodeBlockStyleConfiguration {
    public let content: Content
    public let copyToPasteboard: CopyToPasteboard
    public let theme: ShowcaseCodeBlockTheme
    public let title: Text?

    init(title: Text?, rawValue: String, theme: ShowcaseCodeBlockTheme) {
        self.content = Content(rawValue: rawValue, theme: theme)
        self.copyToPasteboard = CopyToPasteboard(rawValue: rawValue)
        self.theme = theme
        self.title = title
    }
}

// MARK: - Copy To Pasteboard

public extension ShowcaseCodeBlockStyleConfiguration {
    /// A view representing the copy to pasteboard button.
    struct CopyToPasteboard: View {
        /// The text to be copied to the pasteboard.
        let rawValue: String

        #if os(iOS)
        private let impact = UIImpactFeedbackGenerator(style: .light)
        #endif
        
        public var body: some View {
            Button {
                #if os(iOS)
                UIPasteboard.general.string = rawValue
                impact.impactOccurred()
                #endif
            } label: {
                Image(systemName: "doc.on.doc")
            }
        }
    }
}

// MARK: - Content

public extension ShowcaseCodeBlockStyleConfiguration {
    /// A view representing the content of the code block with syntax highlighting.
    struct Content: View {
        var rawValue: String
        var theme: ShowcaseCodeBlockTheme

        @Environment(\.dynamicTypeSize)
        private var typeSize

        public var body: some View {
            Text(makeAttributed(string: rawValue)).textSelection(.enabled)
        }

        private func makeAttributed(string: String) -> AttributedString {
            let format = AttributedStringOutputFormat(theme: splashTheme)
            let highlighter = SyntaxHighlighter(format: format)
            let attributed = AttributedString(highlighter.highlight(string))
            return attributed
        }

        private var splashTheme: Splash.Theme {
            Splash.Theme(
                font: font,
                plainTextColor: theme.plainTextColor,
                tokenColors: theme.tokenColors,
                backgroundColor: theme.backgroundColor
            )
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
    }
}

#Preview {
    ShowcaseCodeBlock(
        Topic.CodeBlock("Example", text: {
"""
HStack {
    Spacer()
    copyButton
}
"""
        }))
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
}
