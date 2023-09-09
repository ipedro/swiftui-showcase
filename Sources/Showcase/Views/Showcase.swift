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
            navigation: .init(view: childrenSelection(scroll)),
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
    

    private func childrenSelection(_ scrollView: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(topic.children) { child in
                    Button(child.name) {
                        withAnimation(.spring()) {
                            scrollView.scrollTo(child.id, anchor: .top)
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

public struct ShowcaseStyleConfiguration {
    public let topic: TopicInfo
    public let level: Int
    public let navigation: Navigation?
    public let subtopics: [TopicInfo]
    
    public struct Navigation: View {
        let view: AnyView
        
        init(view: any View) {
            self.view = .init(view)
        }
        
        public var body: some View {
            view
        }
    }
}

struct Showcase_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Showcase(.accordion)
        }
    }
}
