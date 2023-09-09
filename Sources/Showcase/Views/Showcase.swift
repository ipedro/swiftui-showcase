import SwiftUI

public struct Showcase: View {
    public var topic: ShowcaseTopic
    public var level: Int = .zero
    @Environment(\.showcaseStyle) private var style
    
    private init(_ topic: ShowcaseTopic, level: Int) {
        self.topic = topic
        self.level = level
    }
    
    public init(_ topic: ShowcaseTopic) {
        self.topic = topic
    }
    
    func configuration(scroll: ScrollViewProxy) -> ShowcaseStyleConfiguration {
        .init(
            topic: .init(topic: topic, level: level),
            level: level,
            navigation: topic.children.map { .init(id: $0.id, button: button($0, scroll)) },
            subtopics: topic.children.map { .init(topic: $0, level: level + 1) }
        )
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                style.makeBody(configuration: configuration(scroll: proxy))
            }
            .navigationTitle(Text(topic.name))
        }
    }
    

    fileprivate func button(_ topic: ShowcaseTopic, _ scrollView: ScrollViewProxy) -> Button<Text> {
        Button(topic.name) {
            withAnimation(.spring()) {
                scrollView.scrollTo(topic.id, anchor: .top)
            }
        }
    }

}

public struct ShowcaseStyleConfiguration {
    public let topic: TopicInfo
    public let level: Int
    public let navigation: [NavButton]
    public let subtopics: [TopicInfo]
    
    public struct NavButton: View, Identifiable {
        public let id: String
        let button: Button<Text>
        public var body: some View { button }
    }
}

struct Showcase_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Showcase(.card)
        }
    }
}
