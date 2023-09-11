import SwiftUI

/// A view for showcasing code examples, descriptions, and links.
public struct Showcase: View {
    /// The configuration type for the showcase view.
    typealias Configuration = ShowcaseStyleConfiguration
    
    /// The style environment for the showcase view.
    @Environment(\.showcaseStyle) private var style
    
    /// The data to be displayed in the showcase.
    let data: ShowcaseElement
    
    /// The nesting level of the element.
    let level: Int
    
    /// Initializes a showcase view with the specified data and nesting level.
    /// - Parameters:
    ///   - data: The data to be displayed in the showcase.
    ///   - level: The nesting level of the showcase.
    private init(_ data: ShowcaseElement, level: Int) {
        self.data = data
        self.level = level
    }
    
    /// Initializes a showcase view with the specified data at the root level.
    /// - Parameter data: The data to be displayed in the showcase.
    public init(_ data: ShowcaseElement) {
        self.data = data
        self.level = .zero
    }
    
    /// Generates the showcase configuration based on the provided ScrollViewProxy.
    /// - Parameter scrollView: The ScrollViewProxy to interact with the ScrollView.
    /// - Returns: The showcase configuration.
    func configuration(
        _ scrollView: ScrollViewProxy
    ) -> Configuration {
        Configuration(
            children: ShowcaseChildren(
                data: data.children?.map(\.content),
                level: level + 1,
                parentID: data.id,
                scrollView: scrollView
            ),
            content: ShowcaseContent(
                data: data.content,
                level: level),
            index: ShowcaseIndex(
                configuration: .init(
                    label: .init(
                        data: data.children,
                        scrollView: scrollView))),
            level: level
        )
    }
    
    public var body: some View {
        ScrollViewReader { scrollView in
            let configuration = configuration(scrollView)
            
            ScrollView {
                style.makeBody(configuration: configuration)
            }
            .navigationTitle(Text(data.content.title))
        }
    }
}

/// The configuration for a showcase view.
public struct ShowcaseStyleConfiguration {
    /// The children views within the showcase.
    public let children: ShowcaseChildren?
    
    /// The content view of the showcase.
    public let content: ShowcaseContent
    
    /// The index view for navigating within the showcase.
    public let index: ShowcaseIndex?
    
    /// The nesting level of the showcase.
    public let level: Int
    
}

// MARK: - ShowcaseStyle Extension

public extension ShowcaseStyle where Self == ShowcaseStyleStandard {
    /// The standard showcase style.
    static var standard: Self {
        .init()
    }
}

/// The standard showcase style.
public struct ShowcaseStyleStandard: ShowcaseStyle {
    /// Generates the body of the showcase based on the provided configuration.
    /// - Parameter configuration: The showcase configuration.
    /// - Returns: The body of the showcase.
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
