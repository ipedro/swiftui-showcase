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
struct ShowcaseCodeBlock: View {
    /// The style for displaying code blocks.
    @Environment(\.codeBlockStyle) private var style
    
    /// The configuration for the ShowcaseCodeBlock view.
    typealias Configuration = ShowcaseCodeBlockStyleConfiguration
    
    /// The configuration for the code block.
    let configuration: Configuration
    
    /// Initializes a ShowcaseCodeBlock view with the specified code block data.
    /// - Parameter data: The data representing the code block (optional).
    init?(_ data: ShowcaseTopic.CodeBlock?) {
        guard let data = data else { return nil }
        self.configuration = Configuration(
            title: .init(data.title ?? "Sample Code"),
            content: .init(text: data.rawValue),
            copyToPasteboard: .init(text: data.rawValue)
        )
    }
    
    /// Initializes a ShowcaseCodeBlock view with the provided configuration.
    /// - Parameter configuration: The configuration for the code block.
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    /// The body of the ShowcaseCodeBlock view.
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Default Style

extension ShowcaseCodeBlockStyle where Self == ShowcaseCodeBlockStyleStandard {
    /// The standard style for displaying code blocks.
    static var standard: Self { .init() }
}

/// The standard style for displaying code blocks in ShowcaseCodeBlock.
public struct ShowcaseCodeBlockStyleStandard: ShowcaseCodeBlockStyle {
    public func makeBody(configuration: Configuration) -> some View {
        GroupBox {
            ScrollView(.horizontal) {
                configuration.content
            }
            .padding(.vertical, 10)
        } label: {
            HStack {
                configuration.title
                Spacer()
                configuration.copyToPasteboard
            }
            .foregroundColor(.secondary)
        }
    }
}

/// The configuration for a code block in ShowcaseCodeBlock.
public struct ShowcaseCodeBlockStyleConfiguration {
    /// The title of the code block.
    public let title: Text
    /// The content of the code block.
    public let content: Content
    /// The button to copy the code to the pasteboard.
    public let copyToPasteboard: CopyToPasteboard
    
    /// The view representing the copy to pasteboard button.
    public struct CopyToPasteboard: View {
        /// The text to be copied to the pasteboard.
        let text: String
        
        public var body: some View {
            Button {
                UIPasteboard.general.string = text
            } label: {
                Image(systemName: "doc.on.doc")
            }
        }
    }
    
    /// The view representing the content of the code block with syntax highlighting.
    public struct Content: View {
        /// The text content of the code block.
        let text: String
        /// The color scheme environment variable.
        @Environment(\.colorScheme) private var colorScheme
        
        public var body: some View {
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

struct ShowcaseCodeBlock_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseCodeBlock(
            .init("Example", text: {
"""
HStack {
    Spacer()
    copyButton
}
"""
            }))
    }
}
