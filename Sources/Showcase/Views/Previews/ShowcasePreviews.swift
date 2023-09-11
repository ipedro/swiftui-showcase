import SwiftUI

public struct ShowcasePreviews: View {
    typealias Configuration = ShowcasePreviewsStyleConfiguration
    
    @Environment(\.previewsStyle) private var style
    
    let data: ShowcaseElement.Previews
    
    init?(_ data: ShowcaseElement.Previews?) {
        guard let data = data else { return nil }
        self.data = data
    }
    
    var configuration: Configuration {
        .init(previews: data.content)
    }
    
    public var body: some View {
        GroupBox {
            style.makeBody(configuration: configuration)
                .frame(
                    minWidth: data.minWidth,
                    idealWidth: data.idealWidth,
                    maxWidth: data.maxWidth,
                    minHeight: data.minHeight,
                    idealHeight: data.idealHeight,
                    maxHeight: data.maxHeight,
                    alignment: data.alignment)
        } label: {
            Text(data.title ?? "Previews")
        }
    }
}

// MARK: - Configuration

public struct ShowcasePreviewsStyleConfiguration {
    public typealias Previews = AnyView
    public let previews: Previews
}

// MARK: - Styles

public extension ShowcasePreviewsStyle where Self == ShowcasePreviewsStylePaged {
    static var paged: Self { .init() }
}

public struct ShowcasePreviewsStylePaged: ShowcasePreviewsStyle {
    public func makeBody(configuration: Configuration) -> some View {
        TabView {
            configuration.previews
                .padding(.bottom, 50)
        }
        .tabViewStyle(.page)
        .onAppear(perform: setupPageControl)
    }
    
    private func setupPageControl() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .secondaryLabel
        UIPageControl.appearance().pageIndicatorTintColor = .label.withAlphaComponent(0.15)
    }
}

// MARK: - Previews

struct ShowcasePreviews_Previews: PreviewProvider {
    static let styles: [AnyShowcasePreviewsStyle] = [
        .init(.paged)
    ]
    
    static var previews: some View {
        ForEach(0...styles.count - 1, id: \.self) { index in
            ShowcasePreviews(.init {
                MockPreviews()
            })
        }
    }
}
