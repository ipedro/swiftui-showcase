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
import Engine
import EngineMacros
#if os(iOS)
import UIKit
#endif

// MARK: - View Extension

public extension View {
    /// Sets the style for ``ShowcaseDocument`` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for ``ShowcaseDocument`` instances
    /// within a view:
    ///
    ///     ShowcaseNavigationStack()
    ///         .showcaseCodeBlockStyle(MyCustomStyle())
    ///
    func showcaseCodeBlockStyle<S: ShowcaseCodeBlockStyle>(_ style: S) -> some View {
        modifier(ShowcaseCodeBlockStyleModifier(style))
    }

    func showcaseCodeBlockWordWrap(_ enabled: Bool) -> some View {
        environment(\.codeBlockWordWrap, enabled)
    }

    func showcaseCodeBlockTheme(_ theme: ShowcaseCodeBlockTheme?) -> some View {
        environment(\.codeBlockTheme, theme)
    }
}

/// A view that displays code blocks with syntax highlighting and a copy to pasteboard button.
public struct ShowcaseCodeBlock: StyledView, Equatable {
    public static func == (lhs: ShowcaseCodeBlock, rhs: ShowcaseCodeBlock) -> Bool {
        lhs.id == rhs.id
    }
    
    let title: Optional<Text>
    let sourceCode: String
    let id: UUID

    @Environment(\.codeBlockWordWrap)
    private var wordWrap: Bool

    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.codeBlockTheme)
    private var _theme

    private var theme: ShowcaseCodeBlockTheme {
        _theme ?? Self.theme(for: colorScheme)
    }

    static func theme(for colorScheme: ColorScheme) -> ShowcaseCodeBlockTheme {
        return switch colorScheme {
        case .dark: .xcodeDark
        default: .xcodeLight
        }
    }

    /// Initializes a ShowcaseCodeBlock view with the specified code block data.
    /// - Parameter data: The data representing the code block (optional).
    init?(_ data: Topic.CodeBlock?) {
        guard let data = data else { return nil }
        self.sourceCode = data.rawValue
        title = Text(optional: LocalizedStringKey(optional: data.title))
        self.id = data.id
    }

    public init(_ configuration: ShowcaseCodeBlockConfiguration)   {
        self.title = configuration.title
        self.sourceCode = configuration.sourceCode
        self.id = configuration.id
    }

    public var body: some View {
        ShowcaseCodeBlockRenderer(
            sourceCode: sourceCode,
            title: title,
            wordWrap: wordWrap, 
            theme: theme
        )
    }

    public var _body: some View {
        ShowcaseCodeBlockBody(
            configuration: ShowcaseCodeBlockConfiguration(
                id: id,
                title: title,
                wordWrap: wordWrap,
                sourceCode: sourceCode
            )
        )
    }
}

public struct ShowcaseCodeBlockConfiguration {
    var id: UUID
    public var title: Optional<Text>
    public var wordWrap: Bool
    public var sourceCode: String
}

public protocol ShowcaseCodeBlockStyle: ViewStyle where Configuration == ShowcaseCodeBlockConfiguration {
}

public struct ShowcaseCodeBlockDefaultStyle: ShowcaseCodeBlockStyle {
    public func makeBody(configuration: ShowcaseCodeBlockConfiguration) -> some View {
        _DefaultStyledView(ShowcaseCodeBlock(configuration))
    }
}

private struct ShowcaseCodeBlockBody: ViewStyledView {
    var configuration: ShowcaseCodeBlockConfiguration

    static var defaultStyle: ShowcaseCodeBlockDefaultStyle {
        ShowcaseCodeBlockDefaultStyle()
    }
}

public struct ShowcaseCodeBlockStyleModifier<Style: ShowcaseCodeBlockStyle>: ViewModifier {
    public var style: Style

    public init(_ style: Style) {
        self.style = style
    }

    public func body(content: Content) -> some View {
        content.styledViewStyle(ShowcaseCodeBlockBody.self, style: style)
    }
}

// MARK: - Copy To Pasteboard

struct ShowcaseCodeBlockCopyButton: View {
    /// The text to be copied to the pasteboard.
    let rawValue: String

#if os(iOS)
    private let impact = UIImpactFeedbackGenerator(style: .light)
#endif

    var body: some View {
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

struct ShowcaseCodeBlockRenderer: VersionedView {
    var sourceCode: String
    var title: Text?
    var wordWrap: Bool
    var theme: ShowcaseCodeBlockTheme

    fileprivate func content() -> some View {
        ScrollView(wordWrap ? .vertical : .horizontal) {
            ShowcaseCodeBlockContent(rawValue: sourceCode, theme: theme)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(
                    title == nil ? .bottom : .vertical
                )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
    
    fileprivate func label() -> some View {
        HStack {
            title
            Spacer()
            ShowcaseCodeBlockCopyButton(rawValue: sourceCode)
        }
        .foregroundStyle(Color(theme.plainTextColor))
    }
    
    var v1Body: some View {
        GroupBox(content: content, label: label)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    var v5Body: some View {
        GroupBox(
            content: {
                content().scrollBounceBehavior(.basedOnSize, axes: [
                    .horizontal, 
                    .vertical
                ])
            },
            label: label
        )
        .backgroundStyle(Color(theme.backgroundColor))
    }
}

// MARK: - Content

/// A view representing the content of the code block with syntax highlighting.
struct ShowcaseCodeBlockContent: View {
    var rawValue: String
    var theme: ShowcaseCodeBlockTheme

    @Environment(\.dynamicTypeSize)
    private var typeSize

    var body: some View {
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
