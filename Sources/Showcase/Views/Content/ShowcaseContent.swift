import SwiftUI

public struct ShowcaseContent: View, Identifiable {
    typealias Configuration = ShowcaseContentStyleConfiguration
    
    @Environment(\.showcaseContentStyle) private var style
    public let id: String
    let configuration: Configuration
    
    init(_ id: String, configuration: Configuration) {
        self.id = id
        self.configuration = configuration
    }
    
    init(_ item: ShowcaseItem.Content, _ level: Int) {
        self.id = item.id
        self.configuration = .init(
            level: level,
            title: level > 0 ? .init(item.title) : nil,
            description: .init(item.description),
            previews: .init(item.previews),
            externalLinks: .init(data: item.links),
            snippets: .init(data: item.snippets)
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
