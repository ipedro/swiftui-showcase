import SwiftUI

public struct Showcase: View {
    typealias Configuration = ShowcaseStyleConfiguration
    @Environment(\.showcaseStyle) private var style
    var item: ShowcaseItem
    var level: Int
    
    private init(_ topic: ShowcaseItem, level: Int) {
        self.item = topic
        self.level = level
    }
    
    public init(_ topic: ShowcaseItem) {
        self.item = topic
        self.level = .zero
    }
    
    func configuration(with scrollView: ScrollViewProxy) -> ShowcaseStyleConfiguration {
        return .init(
            anchorLinks: .init(
                data: item.children,
                scrollView: scrollView),
            children: .init(
                data: item.children.map(\.content),
                level: level + 1),
            content: .init(
                data: item.content,
                level: level),
            level: level,
            scrollView: scrollView
        )
    }
    
    public var body: some View {
        ScrollViewReader { scrollView in
            let configuration = configuration(with: scrollView)
            
            ScrollView {
                style.makeBody(configuration: configuration)
            }
            .navigationTitle(Text(item.content.title))
        }
    }
}

public struct ShowcaseStyleConfiguration {
    public let anchorLinks: AnchorLinks?
    public let children: Children?
    public let content: Content
    public let level: Int
    public let scrollView: ScrollViewProxy
    
    public struct Children: View {
        let data: [ShowcaseItem.Content]
        let level: Int
        
        init?(data: [ShowcaseItem.Content], level: Int) {
            if data.isEmpty { return nil }
            self.data = data
            self.level = level
        }
        
        public var body: some View {
            ForEach(data) {
                Content(data: $0, level: level)
            }
        }
    }
    
    public struct AnchorLinks: View {
        let data: [ShowcaseItem]
        let scrollView: ScrollViewProxy
        
        init?(data: [ShowcaseItem], scrollView: ScrollViewProxy) {
            if data.isEmpty { return nil }
            self.data = data
            self.scrollView = scrollView
        }
        
        public var body: some View {
            ForEach(data) {
                AnchorLink(
                    id: $0.id,
                    title: $0.content.title,
                    scrollView: scrollView)
            }
        }
    }
    
}
import SwiftUI

// MARK: - ShowcaseStyle Extension

public extension ShowcaseStyle where Self == ShowcaseStyleStandard {
    /// <#short overview of the system style#>
    static var standard: Self {
        .init()
    }
}

/// An example Showcase style to get you started
public struct ShowcaseStyleStandard: ShowcaseStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            
            configuration.content
            
            if let anchorLinks = configuration.anchorLinks {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack { anchorLinks }
                    }
                }
            }
            
            Section {
                configuration.children
            }
        }
        .padding(configuration.level == .zero ? .horizontal : [])
        .padding(configuration.level == .zero ? [] : .vertical)
    }
    
    private func Section<V: View>(@ViewBuilder content: () -> V) -> some View {
        content()
            .padding(.vertical)
            .padding(.bottom)
            .overlay(alignment: .bottom) {
                Divider()
            }
    }
}

struct Showcase_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Showcase(.card)
        }
    }
}
