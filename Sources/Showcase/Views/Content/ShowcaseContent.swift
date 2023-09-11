import SwiftUI

public struct ShowcaseContent: View {
    typealias Configuration = ShowcaseContentStyleConfiguration
    
    @Environment(\.showcaseContentStyle) private var style
    let data: ShowcaseElement.Content
    let level: Int
    
    var configuration: Configuration {
        .init(
            level: level,
                title: level > 0 ? .init(data.title) : nil,
                description: data.description.isEmpty ? nil : .init(data.description),
                previews: .init(data.previews),
                externalLinks: .init(data: data.links),
                codeBlocks: .init(data: data.codeBlocks)
        )
    }
    
    public var body: some View {
        style
            .makeBody(configuration: configuration)
            .id(data.id)
    }
}

// MARK: - Configuration

public struct ShowcaseContentStyleConfiguration {
    public let level: Int
    public let title: Text?
    public let description: Text?
    public let previews: ShowcasePreviews?
    public let externalLinks: ExternalLinks?
    public let codeBlocks: CodeBlocks?
    
    public struct ExternalLinks: View {
        let data: [ShowcaseElement.ExternalLink]
        
        init?(data: [ShowcaseElement.ExternalLink]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        public var body: some View {
            ForEach(data) {
                ShowcaseExternalLink($0)
            }
        }
    }
    
    public struct CodeBlocks: View {
        let data: [ShowcaseElement.CodeBlock]
        
        init?(data: [ShowcaseElement.CodeBlock]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        public var body: some View {
            ForEach(data) {
                ShowcaseCodeBlock($0)
            }
        }
    }
}

// MARK: - Standard Style

extension ShowcaseContentStyle where Self == ShowcaseContentStyleStandard {
    static var standard: Self { .init() }
}

struct ShowcaseContentStyleStandard: ShowcaseContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        LazyVStack(alignment: .leading, spacing: 30) {
            configuration.title
                .font(.system(title(configuration.level)))
            
            if let externalLinks = configuration.externalLinks {
                LazyHStack {
                    externalLinks
                }
            }
            
            configuration.previews
            
            configuration.description
                .font(.system(description(configuration.level)))
            
            configuration.codeBlocks
                .padding(.top)
        }
    }
    
    private func title(_ level: Int) -> SwiftUI.Font.TextStyle{
        switch level {
        case 0: return .largeTitle
        case 1: return .title
        default: return .title2
        }
    }
    
    private func description(_ level: Int) -> SwiftUI.Font.TextStyle {
        switch level {
        case 0: return .subheadline
        case 1: return .body
        default: return .caption
        }
    }
}

// MARK: - Previews

struct ShowcaseContent_Previews: PreviewProvider {
    static let styles: [AnyShowcaseContentStyle] = [
        .init(.standard)
    ]
    
    static var previews: some View {
        ForEach(0...styles.count - 1, id: \.self) { index in
            ScrollView {
                ShowcaseContent(data: ShowcaseElement.accordion.content, level: index)
                    .showcaseContentStyle(styles[index])
                    .padding()
            }
        }
    }
}
