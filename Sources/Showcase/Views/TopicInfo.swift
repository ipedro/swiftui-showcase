import SwiftUI

public struct TopicInfo: View, Identifiable {
    @State private var expandDescription = false
    public var id: String { topic.id }
    var topic: ShowcaseTopic
    var level: Int = 1
    
    public var body: some View {
        if level > 0 {
            headline
        }
        
        links
        
        Previews(content: topic.previews)
            .aspectRatio(
                topic.previewRatio.width / topic.previewRatio.height,
                contentMode: .fit)
        
        description
        
        VStack {
            ForEach(topic.codeExamples) {
                CodeExample($0)
            }
        }
    }
    
    private var headline: some View {
        Text(topic.name)
            .font(.system(headline(level)))
    }
    
    private var description: some View {
        Text(topic.description)
            .font(.system(body(level)))
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
    
    @ViewBuilder private var links: some View {
        HStack {
            ForEach(topic.links) { link in
                TopicLink(link.name.description, url: link.url)
            }
        }
        .foregroundColor(.accentColor)
        .padding(.vertical)
    }
}

struct ShowcaseTopicInfo_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TopicInfo(topic: .accordion)
        }
    }
}
