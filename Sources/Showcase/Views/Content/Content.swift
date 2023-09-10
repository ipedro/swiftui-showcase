import SwiftUI

public struct Content: View, Identifiable {
    typealias Configuration = ShowcaseContentStyleConfiguration
    
    @Environment(\.showcaseContentStyle) private var style
    let data: ShowcaseItem.Content
    let level: Int
    
    public var id: String {
        data.id
    }
    
    var configuration: Configuration {
        .init(
            level: level,
                title: level > 0 ? .init(data.title) : nil,
                description: .init(data.description),
                previews: .init(data.previews),
                externalLinks: .init(data: data.links),
                snippets: .init(data: data.snippets)
        )
    }
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
}

public struct ShowcaseContentStyleConfiguration {
    public let level: Int
    public let title: Text?
    public let description: Text
    public let previews: Previews?
    public let externalLinks: ExternalLinks?
    public let snippets: CodeBlocks?
    
    public struct ExternalLinks: View {
        let data: [ShowcaseItem.ExternalLink]
        
        init?(data: [ShowcaseItem.ExternalLink]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        public var body: some View {
            ForEach(data) { ExternalLink($0) }
        }
    }
    
    public struct CodeBlocks: View {
        let data: [ShowcaseItem.CodeBlock]
        
        init?(data: [ShowcaseItem.CodeBlock]) {
            if data.isEmpty { return nil }
            self.data = data
        }
        
        public var body: some View {
            ForEach(data) { ShowcaseCodeBlock($0) }
        }
    }
}

extension ShowcaseContentStyle where Self == ShowcaseContentStyleStandard {
    static var standard: Self { .init() }
}

struct ShowcaseContentStyleStandard: ShowcaseContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            configuration.title
                .font(.system(title(configuration.level)))
            
            ScrollView {
                HStack {
                    configuration.externalLinks
                }
            }
            
            configuration.previews
            
            configuration.description
                .font(.system(description(configuration.level)))
            
            configuration.snippets
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
