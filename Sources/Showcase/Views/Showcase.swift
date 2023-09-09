import SwiftUI

public struct Showcase: View {
    public var topic: ShowcaseTopic
    public var level: Int = .zero
    
    private init(_ topic: ShowcaseTopic, level: Int) {
        self.topic = topic
        self.level = level
    }
    
    public init(_ topic: ShowcaseTopic) {
        self.topic = topic
    }
    
    public var body: some View {
        ScrollViewReader { scrollView in
            ScrollView {
                VStack(alignment: .leading) {
                    
                    TopicInfo(
                        topic: topic,
                        level: level)
                    
                    childrenSelection(scrollView)
                    
                    children
                }
                .padding(.horizontal, level == .zero ? 20 : .zero)
                .padding(.vertical, level == .zero ? 0 : 24)
                .navigationTitle(Text(topic.name))
            }
        }
    }
    
    @ViewBuilder private var children: some View {
        if !topic.children.isEmpty {
            Divider()
            
            ForEach(topic.children) { child in
                VStack(alignment: .leading) {
                    TopicInfo(
                        topic: child,
                        level: level + 1)
                }
                .padding(.vertical)
                Divider()
            }
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
