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
import Engine
import EngineMacros

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

public struct ShowcaseCodeBlocks: View {
    var content: EquatableForEach<[Topic.CodeBlock], Topic.CodeBlock.ID, ShowcaseCodeBlock>
    public var body: some View { content }
}

/// A view that displays code blocks with syntax highlighting and a copy to pasteboard button.
public struct ShowcaseCodeBlock: StyledView, Equatable {
    public static func == (lhs: ShowcaseCodeBlock, rhs: ShowcaseCodeBlock) -> Bool {
        lhs.id == rhs.id
    }
    
    let title: Optional<Text>
    let sourceCode: String
    let id: UUID

    /// Initializes a ShowcaseCodeBlock view with the specified code block data.
    /// - Parameter data: The data representing the code block (optional).
    init(data: Topic.CodeBlock) {
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
        ShowcaseCodeBlockContent(sourceCode: sourceCode, title: title)
    }

    public var _body: some View {
        ShowcaseCodeBlockBody(
            configuration: ShowcaseCodeBlockConfiguration(
                id: id,
                title: title,
                sourceCode: sourceCode
            )
        )
    }
}

public struct ShowcaseCodeBlockConfiguration {
    var id: UUID
    public var title: Optional<Text>
    public var sourceCode: String
}

public protocol ShowcaseCodeBlockStyle: ViewStyle where Configuration == ShowcaseCodeBlockConfiguration {}

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

#Preview {
    ShowcaseCodeBlock(
        data: Topic.CodeBlock("Example", text: {
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
        data: Topic.CodeBlock(text: {
        """
        HStack {
            Spacer()
            copyButton
        }
        """
        }))
}
