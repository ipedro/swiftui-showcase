import SwiftUI

public struct Showcase: View {
    typealias Configuration = ShowcaseStyleConfiguration
    @Environment(\.showcaseStyle) private var style
    var data: ShowcaseItem
    var level: Int
    
    private init(_ data: ShowcaseItem, level: Int) {
        self.data = data
        self.level = level
    }
    
    public init(_ data: ShowcaseItem) {
        self.data = data
        self.level = .zero
    }
    
    func configuration(with scrollView: ScrollViewProxy) -> ShowcaseStyleConfiguration {
        return .init(
            children: .init(
                data: data.children?.map(\.content),
                level: level + 1,
                parentID: data.id,
                scrollView: scrollView
            ),
            content: .init(
                data: data.content,
                level: level),
            index: .init(
                configuration: .init(
                    label: .init(
                        data: data.children,
                        scrollView: scrollView))),
            level: level
        )
    }
    
    public var body: some View {
        ScrollViewReader { scrollView in
            let configuration = configuration(with: scrollView)
            
            ScrollView {
                style.makeBody(configuration: configuration)
            }
            .navigationTitle(Text(data.content.title))
        }
    }
}

public struct ShowcaseStyleConfiguration {
    public let children: Children?
    public let content: ShowcaseContent
    public let index: ShowcaseIndex?
    public let level: Int
    
    public struct Children: View {
        let data: [ShowcaseItem.Content]
        let level: Int
        let parentID: ShowcaseItem.ID
        let scrollView: ScrollViewProxy
        
        init?(
            data: [ShowcaseItem.Content]?,
            level: Int,
            parentID: ShowcaseItem.ID,
            scrollView: ScrollViewProxy
        ) {
            guard let data = data, !data.isEmpty else { return nil }
            self.data = data
            self.level = level
            self.parentID = parentID
            self.scrollView = scrollView
        }
        
        public var body: some View {
            ForEach(data) { item in
                ZStack(alignment: .topTrailing) {
                    ShowcaseContent(data: item, level: level)
                    
                    Button {
                        withAnimation {
                            scrollView.scrollTo(parentID)
                        }
                    } label: {
                        Image(systemName: "chevron.up")
                    }
                    .padding(.top, 12)
                }
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
        LazyVStack(alignment: .leading) {
            
            configuration.content
            
            if let index = configuration.index {
                index.padding(.vertical)
                Divider()
            }
            
            configuration.children
                .padding(.vertical)
                .padding(.bottom)
                .overlay(alignment: .bottom) {
                    Divider()
                }
            
        }
        .padding(configuration.level == .zero ? .horizontal : [])
        .padding(configuration.level == .zero ? [] : .vertical)
        .toolbar {
            ToolbarItem {
                configuration.index
                    .showcaseIndexStyle(.menu)
            }
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
