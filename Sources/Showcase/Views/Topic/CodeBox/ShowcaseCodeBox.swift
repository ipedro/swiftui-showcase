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
@_implementationOnly import Splash

/// A view that displays code blocks with syntax highlighting and a copy to pasteboard button.
struct ShowcaseCodeBox: View {
    /// The style for displaying code blocks.
    @Environment(\.codeBoxStyle) private var style
    
    let data: Topic.CodeBlock
    
    /// Initializes a ShowcaseCodeBox view with the specified code block data.
    /// - Parameter data: The data representing the code block (optional).
    init?(_ data: Topic.CodeBlock?) {
        guard let data = data else { return nil }
        self.data = data
    }

    var body: some View {
        let content = data.rawValue
        GroupBox {
            ScrollView(.horizontal) {
                Content(text: content)
            }
        } label: {
            HStack {
                Text(data.title)
                Spacer()
                CopyToPasteboard(text: content)
            }
        }
        .groupBoxStyle(AnyGroupBoxStyle(style))
    }

    // MARK: - CopyToPasteboard

    /// A view representing the copy to pasteboard button.
    private struct CopyToPasteboard: View {
        /// The text to be copied to the pasteboard.
        let text: String

        private let impact = UIImpactFeedbackGenerator(style: .light)

        var body: some View {
            Button {
                UIPasteboard.general.string = text
                impact.impactOccurred()
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .onAppear(perform: impact.prepare)
        }
    }

    // MARK: - Content

    /// A view representing the content of the code block with syntax highlighting.
    private struct Content: View {
        /// The text content of the code block.
        let text: String
        /// The color scheme environment variable.
        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            Text(decorated(text, colorScheme))
                .textSelection(.enabled)
        }

        /// Applies syntax highlighting and creates an AttributedString for the code block content.
        /// - Parameters:
        ///   - text: The text content of the code block.
        ///   - scheme: The color scheme.
        /// - Returns: An AttributedString with syntax highlighting.
        private func decorated(_ text: String, _ scheme: ColorScheme) -> AttributedString {
            let theme = theme(scheme)
            let format = AttributedStringOutputFormat(theme: theme)
            let highlighter = SyntaxHighlighter(format: format)
            let attributed = AttributedString(highlighter.highlight(text))
            return attributed
        }

        /// Retrieves the theme for syntax highlighting based on the color scheme.
        /// - Parameter colorScheme: The color scheme.
        /// - Returns: The theme for syntax highlighting.
        private func theme(_ colorScheme: ColorScheme) -> Theme {
            switch colorScheme {
            case .dark: return .xcodeDark(withFont: .init(size: 14))
            default: return .presentation(withFont: .init(size: 14))
            }
        }
    }
}

#Preview {
    ShowcaseCodeBox(
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
    ShowcaseCodeBox(
        Topic.CodeBlock(text: {
"""
HStack {
    Spacer()
    copyButton
}
"""
        }))
    //.showcaseCodeBoxStyle(.automatic(background: .red))
}
