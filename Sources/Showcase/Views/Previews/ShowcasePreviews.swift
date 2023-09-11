import SwiftUI

public struct ShowcasePreviews: View {
    typealias Configuration = ShowcasePreviewsStyleConfiguration
    @Environment(\.previewsStyle) private var style
    let configuration: Configuration
    
    init?(_ data: ShowcaseItem.Previews?) {
        guard let data = data else { return nil }
        self.configuration = .init(
            aspectRatio: data.aspectRatio,
            previews: data.previews)
    }
    
    init(_ configuration: Configuration) {
        self.configuration = configuration
    }
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Configuration

public struct ShowcasePreviewsStyleConfiguration {
    public typealias Previews = AnyView
    public let aspectRatio: CGFloat
    public let previews: Previews
}

// MARK: - Style

public extension ShowcasePreviewsStyle where Self == ShowcasePreviewsStylePaged {
    static var paged: Self { .init() }
}

public struct ShowcasePreviewsStylePaged: ShowcasePreviewsStyle {
    public func makeBody(configuration: Configuration) -> some View {
        GroupBox {
            TabView {
                configuration.previews
            }
            .tabViewStyle(.page)
            .aspectRatio(configuration.aspectRatio, contentMode: .fit)
        } label: {
            Text("Previews")
                .foregroundColor(.secondary)
        }
        .onAppear(perform: setupPageControl)
    }
    
    private func setupPageControl() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().pageIndicatorTintColor = .label.withAlphaComponent(0.3)
    }
}
