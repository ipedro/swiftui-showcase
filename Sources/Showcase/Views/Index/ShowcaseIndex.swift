import SwiftUI

public struct ShowcaseIndex: View {
    @Environment(\.indexStyle) private var style
    typealias Configuration = ShowcaseIndexStyleConfiguration
    let configuration: Configuration
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Configuration

public struct ShowcaseIndexStyleConfiguration {
    /// A type-erased collection of anchor buttons
    public let label: Label?
    
    /// A type-erased collection of anchor buttons
    public struct Label: View {
        let data: [ShowcaseItem]
        let scrollView: ScrollViewProxy
        
        init?(data: [ShowcaseItem]?, scrollView: ScrollViewProxy) {
            guard let data = data, !data.isEmpty else { return nil }
            self.data = data
            self.scrollView = scrollView
        }
        
        public var body: some View {
            ForEach(data) { item in
                Button(item.content.title) {
                    withAnimation(.spring()) {
                        scrollView.scrollTo(item.id, anchor: .top)
                    }
                }
            }
        }
    }

}

// MARK: - Styles

public extension ShowcaseIndexStyle where Self == ShowcaseIndexStyleVStack {
    static var vertical: Self { .init() }
}

public struct ShowcaseIndexStyleVStack: ShowcaseIndexStyle {
    public func makeBody(configuration: Configuration) -> some View {
        LazyVStack(alignment: .leading) {
            configuration.label
                .padding(.horizontal)
                .padding(.vertical, 2)
                .overlay(alignment: .leading) {
                    Circle()
                        .frame(width: 6)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 25)
        }
    }
}

public extension ShowcaseIndexStyle where Self == ShowcaseIndexStyleMenu {
    static var menu: Self { .init() }
}

public struct ShowcaseIndexStyleMenu: ShowcaseIndexStyle {
    private let shape = RoundedRectangle(
        cornerRadius: 8,
        style: .continuous)
    
    public func makeBody(configuration: Configuration) -> some View {
        if let label = configuration.label {
            Menu {
                label
            } label: {
                Image(systemName: "list.bullet")
                    .padding(5)
                    .mask { shape }
                    .background {
                        shape
                            .opacity(0.2)
                    }
            }
        }
    }
}

struct ShowcaseIndex_Previews: PreviewProvider {
    static var previews: some View {
        ScrollViewReader { scroll in
            ShowcaseIndex(
                configuration: .init(
                    label: .init(
                        data: [
                            .staticCard,
                            .navigationalCard,
                            .selectableCard,
                            .accordion
                        ],
                        scrollView: scroll)))
            //.showcaseIndexStyle(.menu)
        }
    }
}
