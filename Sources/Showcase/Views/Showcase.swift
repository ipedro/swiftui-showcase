import SwiftUI

public struct Showcase: View {
    var item: ShowcaseItem
    var level: Int = .zero
    @Environment(\.showcaseStyle) private var style
    
    private init(_ topic: ShowcaseItem, level: Int) {
        self.item = topic
        self.level = level
    }
    
    public init(_ topic: ShowcaseItem) {
        self.item = topic
    }
    
    func configuration(scroll: ScrollViewProxy) -> ShowcaseStyleConfiguration {
        .init(
            level: level,
            label: .init(item: item.section, level: level),
            scrollView: scroll,
            navigation: item.children.map { .init(id: $0.id, button: button($0, scroll)) },
            sections: item.children.map { .init(item: $0.section, level: level + 1) }
        )
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                style.makeBody(configuration: configuration(scroll: proxy))
            }
            .navigationTitle(Text(item.section.name))
        }
    }
    

    fileprivate func button(_ topic: ShowcaseItem, _ scrollView: ScrollViewProxy) -> Button<Text> {
        Button(topic.section.name) {
            withAnimation(.spring()) {
                scrollView.scrollTo(topic.id, anchor: .top)
            }
        }
    }

}

public struct ShowcaseStyleConfiguration {
    public let level: Int
    public let label: ShowcaseSection
    public let scrollView: ScrollViewProxy
    public let navigation: [NavButton]
    public let sections: [ShowcaseSection]
    
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
