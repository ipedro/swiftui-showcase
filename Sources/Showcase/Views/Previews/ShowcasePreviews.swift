import SwiftUI

/// A view that displays previews of showcase elements.
public struct ShowcasePreviews: View {
    /// The style configuration for ShowcasePreviews.
    typealias Configuration = ShowcasePreviewsStyleConfiguration
    
    /// The style for displaying the previews.
    @Environment(\.previewsStyle) private var style
    
    /// The data representing the previews.
    let data: ShowcaseElement.Previews
    
    /// Initializes a ShowcasePreviews view with the specified previews data.
    /// - Parameter data: The data representing the previews (optional).
    init?(_ data: ShowcaseElement.Previews?) {
        guard let data = data else { return nil }
        self.data = data
    }
    
    /// The configuration for the ShowcasePreviews view.
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
    /// The type-erased previews content.
    public typealias Previews = AnyView
    /// The previews content.
    public let previews: Previews
}

// MARK: - Styles

public extension ShowcasePreviewsStyle where Self == ShowcasePreviewsStylePaged {
    /// A paged style for ShowcasePreviews.
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
    
    /// Sets up the appearance of the page control for paged previews.
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
