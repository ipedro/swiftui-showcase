import SwiftUI

public struct ShowcaseSection: View, Identifiable {
    @Environment(\.showcaseSectionStyle) private var style
    public var id: String { item.id }
    var item: ShowcaseItem.Section
    var level: Int = 1
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
    
    private var configuration: ShowcaseSectionStyleConfiguration {
        .init(
            level: level,
            headline: level > 0 ? .init(item.name) : nil,
            description: .init(item.description),
            previews: .init(item.previews),
            links: item.links.compactMap { .init($0.name.description, url: $0.url) },
            codeExamples: item.codeExamples.compactMap { .init($0) }
        )
    }
    
//    private var headline: some View {,
//        Text(item.name)
//            .font(.system(headline(level)))
//    }
//
//    private var description: some View {
//        Text(item.description)
//            .font(.system(body(level)))
//    }
    
}

public struct ShowcaseSectionStyleConfiguration {
    public let level: Int
    public let headline: Text?
    public let description: Text
    public let previews: Previews?
    public let links: [SectionLink]
    public let codeExamples: [CodeExample]
}

extension ShowcaseSectionStyle where Self == ShowcaseSectionStyleSystem {
    static var system: Self { .init() }
}

struct ShowcaseSectionStyleSystem: ShowcaseSectionStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.headline
            .font(.system(headline(configuration.level)))
        
        HStack {
            ForEach(configuration.links) { link in
                SectionLink(link.name.description, url: link.url)
            }
        }
        .foregroundColor(.accentColor)
        .padding(.vertical)

        configuration.description
            .font(.system(body(configuration.level)))

        VStack {
            ForEach(configuration.codeExamples) { $0 }
        }
    }
    
    private func headline(_ level: Int) -> Font.TextStyle{
        switch level {
        case 0: return .largeTitle
        case 1: return .title
        default: return .title2
        }
    }
    
    private func body(_ level: Int) -> Font.TextStyle {
        switch level {
        case 0: return .subheadline
        case 1: return .body
        default: return .caption
        }
    }
}
