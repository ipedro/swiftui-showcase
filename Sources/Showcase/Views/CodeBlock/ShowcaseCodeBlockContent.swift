import SwiftUI
import Splash

/// A view representing the content of the code block with syntax highlighting.
struct ShowcaseCodeBlockContent: View {
    var sourceCode: String
    var title: Text?

    @Environment(\.dynamicTypeSize)
    private var typeSize

    @Environment(\.codeBlockWordWrap)
    private var wordWrap: Bool

    @Environment(\.codeBlockTheme)
    private var _theme

    @Environment(\.colorScheme)
    private var colorScheme

    private var theme: ShowcaseCodeBlockTheme {
        _theme ?? Self.theme(for: colorScheme)
    }

    static func theme(for colorScheme: ColorScheme) -> ShowcaseCodeBlockTheme {
        return switch colorScheme {
        case .dark: .xcodeDark
        default: .xcodeLight
        }
    }

    private var content: some View {
        ScrollView(wordWrap ? .vertical : .horizontal) {
            Text(makeAttributed(sourceCode)).textSelection(.enabled)
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .padding(
                    title == nil ? .vertical : .bottom
                )
        }
        .fixedSize(horizontal: false, vertical: true)
        .scrollBounceBehavior(.basedOnSize, axes: [.horizontal, .vertical])
    }

    private var copyButton: ShowcaseCodeBlockCopyButton {
        ShowcaseCodeBlockCopyButton(rawValue: sourceCode)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            GroupBox {
                content
            } label: {
                if let title {
                    title.foregroundStyle(Color(theme.plainTextColor))
                }
            }
            .backgroundStyle(Color(theme.backgroundColor))

            copyButton.padding(5)
        }
    }

    private func makeAttributed(_ string: String) -> AttributedString {
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
