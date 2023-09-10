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
            anchorLinks: item.children.map { .init($0, scrollView) },
            label: .init(item.content, level),
            level: level,
            scrollView: scrollView,
            sections: item.children.map { .init($0.content, level + 1) }
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
    public let anchorLinks: [ShowcaseAnchorLink]
    public let label: ShowcaseContent
    public let level: Int
    public let scrollView: ScrollViewProxy
    public let sections: [ShowcaseContent]
    
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
            
            configuration.label
            
            if !configuration.sections.isEmpty {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(configuration.anchorLinks) { button in
                            button
                        }
                    }
                }
                .padding(.vertical)
            
                Divider()
                
                ForEach(configuration.sections) { section in
                    VStack(alignment: .leading) {
                        section
                    }
                    .padding(.vertical)
                    
                    Divider()
                }
            }
        }
        .padding(.horizontal, configuration.level == .zero ? 20 : .zero)
        .padding(.vertical, configuration.level == .zero ? 0 : 24)
    }
}

struct Showcase_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Showcase(.card)
        }
    }
}
