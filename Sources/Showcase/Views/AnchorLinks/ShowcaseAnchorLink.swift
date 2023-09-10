import SwiftUI

public struct ShowcaseAnchorLink: View, Identifiable {
    public let id: String
    private let button: Button<Text>
    public var body: some View { button }
    
    init(_ topic: ShowcaseItem, _ scrollView: ScrollViewProxy) {
        id = topic.id
        button = Button(topic.content.title) {
            withAnimation(.spring()) {
                scrollView.scrollTo(topic.id, anchor: .top)
            }
        }
    }
}
