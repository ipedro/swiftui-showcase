import SwiftUI

/// A view that displays navigation anchors to children elements within a Showcase view.
public struct ShowcaseIndex: View {
    typealias Configuration = ShowcaseIndexStyleConfiguration
    
    /// The style for displaying the index.
    @Environment(\.indexStyle) private var style
    
    /// The configuration for the ShowcaseIndex view.
    let configuration: Configuration
    
    /// Initializes a ShowcaseIndex view with the specified configuration.
    /// - Parameter configuration: The configuration for the ShowcaseIndex view.
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Configuration

public struct ShowcaseIndexStyleConfiguration {
    /// A type-erased collection of anchor buttons.
    public let label: Label?
    
    /// A type-erased collection of anchor buttons.
    public struct Label: View {
        /// The data representing showcase elements.
        let data: [ShowcaseElement]
        
        /// The scroll view proxy for scrolling to anchor points.
        let scrollView: ScrollViewProxy?
        
        /// Initializes a label with the specified data and scroll view proxy.
        /// - Parameters:
        ///   - data: The data representing showcase elements.
        ///   - scrollView: The scroll view proxy for scrolling to anchor points (optional).
        init?(data: [ShowcaseElement]?, scrollView: ScrollViewProxy? = nil) {
            guard let data = data, !data.isEmpty else { return nil }
            self.data = data
            self.scrollView = scrollView
        }
        
        /// The body of the label view.
        public var body: some View {
            ForEach(data) { item in
                Button(item.content.title) {
                    withAnimation {
                        scrollView?.scrollTo(item.id, anchor: .top)
                    }
                }
            }
        }
    }
}

// MARK: - Styles

public extension ShowcaseIndexStyle where Self == ShowcaseIndexStyleBulletList {
    /// A bullet list style.
    static var bulletList: Self { .init() }
}

public extension ShowcaseIndexStyle where Self == ShowcaseIndexStyleMenu {
    /// A context menu style.
    static var menu: Self { .init() }
}

public struct ShowcaseIndexStyleBulletList: ShowcaseIndexStyle {
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

public struct ShowcaseIndexStyleMenu: ShowcaseIndexStyle {
    /// The shape used for the menu style.
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
                        shape.opacity(0.1)
                    }
            }
        }
    }
}

// MARK: - Previews

struct ShowcaseIndex_Previews: PreviewProvider {
    static let styles: [AnyShowcaseIndexStyle] = [
        .init(.menu),
        .init(.bulletList)
    ]
    
    static var previews: some View {
        ForEach(0...styles.count - 1, id: \.self) { index in
            ShowcaseIndex(
                configuration: .init(
                    label: .init(data: [
                        .staticCard,
                        .navigationalCard,
                        .selectableCard,
                        .accordion
                    ])
                )
            )
            .showcaseIndexStyle(styles[index])
        }
    }
}
