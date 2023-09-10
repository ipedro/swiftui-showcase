import SwiftUI
import Splash

struct ShowcaseCodeBlock: View, Identifiable {
    @Environment(\.snippetStyle) private var style
    
    typealias Configuration = ShowcaseCodeBlockStyleConfiguration
    
    let id: String
    
    let configuration: Configuration
    
    init?(_ data: ShowcaseItem.CodeBlock?) {
        guard let data = data else { return nil }
        self.id = data.id
        self.configuration = .init(
            title: .init(data.title ?? "Sample Code"),
            content: .init(text: data.rawValue),
            copyToPasteboard: .init(text: data.rawValue)
        )
    }
    
    init(_ id: String, configuration: Configuration) {
        self.id = id
        self.configuration = configuration
    }
    
    var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Default Style

extension ShowcaseCodeBlockStyle where Self == ShowcaseCodeBlockStyleStandard {
    static var standard: Self { .init() }
}

public struct ShowcaseCodeBlockStyleStandard: ShowcaseCodeBlockStyle {
    public func makeBody(configuration: Configuration) -> some View {
        GroupBox {
            ScrollView(.horizontal) {
                configuration.content
            }
        } label: {
            HStack {
                configuration.title
                Spacer()
                configuration.copyToPasteboard
            }
            .foregroundColor(.primary)
        }
    }
}

public struct ShowcaseCodeBlockStyleConfiguration {
    public let title: Text
    public let content: Content
    public let copyToPasteboard: CopyToPasteboard
    
    public struct CopyToPasteboard: View {
        var text: String
        public var body: some View {
            Button {
                UIPasteboard.general.string = text
            } label: {
                Image(systemName: "doc.on.doc")
            }
        }
    }
    
    public struct Content: View {
        let text: String
        @Environment(\.colorScheme) private var colorScheme
        
        public var body: some View {
            Text(decorated(text, colorScheme))
                .textSelection(.enabled)
        }
        
        private func decorated(_ text: String, _ scheme: ColorScheme) -> AttributedString {
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
}

struct ShowcaseCodeBlock_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseCodeBlock(
            .init("Example", text: { """
HStack {
    Spacer()
    copyButton
}
"""
            }))
    }
}
