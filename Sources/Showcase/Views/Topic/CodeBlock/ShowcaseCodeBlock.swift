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

/// A view that displays code blocks with syntax highlighting and a copy to pasteboard button.
struct ShowcaseCodeBlock: View {
    typealias Configuration = ShowcaseCodeBlockStyleConfiguration
    /// The style for displaying code blocks.
    @Environment(\.codeBlockStyle) 
    private var style

    var data: Topic.CodeBlock

    /// Initializes a ShowcaseCodeBlock view with the specified code block data.
    /// - Parameter data: The data representing the code block (optional).
    init?(_ data: Topic.CodeBlock?) {
        guard let data = data else { return nil }
        self.data = data
    }

    var configuration: Configuration {
        Configuration(
            content: Configuration.Content(
                rawValue: data.rawValue,
                theme: style.makeTheme(colorScheme:)
            ),
            copyToPasteboard: Configuration.CopyToPasteboard(
                rawValue: data.rawValue
            ),
            title: Text(optional: LocalizedStringKey(optional: data.title))
        )
    }

    var body: some View {
        AnyView(style.resolve(configuration: configuration))
    }
}

public struct ShowcaseCodeBlockStyleConfiguration {
    public let content: Content
    public let copyToPasteboard: CopyToPasteboard
    public let title: Text?
}

// MARK: - Copy To Pasteboard

public extension ShowcaseCodeBlockStyleConfiguration {
    /// A view representing the copy to pasteboard button.
    struct CopyToPasteboard: View {
        /// The text to be copied to the pasteboard.
        let rawValue: String

        private let impact = UIImpactFeedbackGenerator(style: .light)

        public var body: some View {
            Button {
                UIPasteboard.general.string = rawValue
                impact.impactOccurred()
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .onAppear(perform: impact.prepare)
        }
    }
}

// MARK: - Content

public extension ShowcaseCodeBlockStyleConfiguration {
    /// A view representing the content of the code block with syntax highlighting.
    struct Content: View {
        let rawValue: String
        let theme: (ColorScheme) -> Theme
        @Environment(\.colorScheme)
        private var colorScheme

        public var body: some View {
            Text(makeAttributed(string: rawValue)).textSelection(.enabled)
        }

        private func makeAttributed(string: String) -> AttributedString {
            let theme = theme(colorScheme)
            let format = AttributedStringOutputFormat(theme: theme)
            let highlighter = SyntaxHighlighter(format: format)
            let attributed = AttributedString(highlighter.highlight(string))
            return attributed
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
    //.showcaseCodeBlockStyle(.automatic(background: .red))
}

import SwiftUI

extension Theme {
    static func xcodeDark(withFont font: Splash.Font) -> Theme {
        return Theme(
            font: font,
            plainTextColor: .init(white: 1, alpha: 0.85),
            tokenColors: [
                .keyword: .init(rgb: 0xFC83B7),
                .string: .init(rgb: 0xFC6A5D),
                .type: .init(rgb: 0xD0A8FF),
                .call: .init(rgb: 0xD0A8FF),
                .number: .init(rgb: 0xD0BF69),
                .comment: .init(rgb: 0x6C7986),
                .property: .init(white: 1, alpha: 0.85),
                .dotAccess: .init(rgb: 0xD0A8FF),
                .preprocessing: .init(rgb: 0xFD8F3F)
            ],
            backgroundColor: .init(rgb: 0x292A2F)
        )
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}


extension SwiftUI.Color {
    init(rgb: Int) {
        self = Color(UIColor(rgb: rgb))
    }
}
