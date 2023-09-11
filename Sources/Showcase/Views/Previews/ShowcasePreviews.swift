import SwiftUI

public struct ShowcasePreviews: View {
    typealias Configuration = ShowcasePreviewsStyleConfiguration
    @Environment(\.previewsStyle) private var style
    let data: ShowcaseItem.Previews
    
    init?(_ data: ShowcaseItem.Previews?) {
        guard let data = data else { return nil }
        self.data = data
    }
    
    var configuration: Configuration {
        .init(previews: data.content)
    }
    
    public var body: some View {
        style.makeBody(configuration: configuration)
            .frame(
                minWidth: data.minWidth,
                idealWidth: data.idealWidth,
                maxWidth: data.maxWidth,
                minHeight: data.minHeight,
                idealHeight: data.idealHeight,
                maxHeight: data.maxHeight,
                alignment: data.alignment)
    }
}

// MARK: - Configuration

public struct ShowcasePreviewsStyleConfiguration {
    public typealias Previews = AnyView
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
                    .padding(.bottom, 44)
            }
            .tabViewStyle(.page)
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

