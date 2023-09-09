import SwiftUI
@_implementationOnly import Splash

struct CodeExample: View {
    @Environment(\.colorScheme) private var colorScheme
    var code: ShowcaseTopic.CodeExample
    
    init?(_ code: ShowcaseTopic.CodeExample?) {
        guard let code = code else { return nil }
        self.code = code
    }
    
    var body: some View {
        GroupBox(content: content, label: label)
            .padding(.vertical)
    }
    
    private func content() -> some View {
        ScrollView(.horizontal) {
            Text(code.attributedString(colorScheme))
                .textSelection(.enabled)
        }
    }
    
    private func label() -> some View {
        HStack {
            Text(code.title)
            Spacer()
            copyButton
        }
        .foregroundColor(.primary)
    }
    
    private var copyButton: some View {
        Button {
            UIPasteboard.general.string = code.text
        } label: {
            Image(systemName: "doc.on.doc")
        }
    }
}

private extension ShowcaseTopic.CodeExample {
    func attributedString(_ scheme: ColorScheme) -> AttributedString {
        let theme = theme(scheme)
        let format = AttributedStringOutputFormat(theme: theme)
        let highlighter = SyntaxHighlighter(format: format)
        let attributed = AttributedString(highlighter.highlight(text))
        return attributed
    }
    
    private func theme(_ colorScheme: ColorScheme) -> Theme {
        switch colorScheme {
        case .dark: return .xcodeDark(withFont: .init(size: 14))
        default: return .presentation(withFont: .init(size: 14))
        }
    }
}

struct CodeExample_Previews: PreviewProvider {
    static var previews: some View {
        CodeExample(
            .init("Example", text: { """
HStack {
    Spacer()
    copyButton
}
"""
            }))
    }
}
