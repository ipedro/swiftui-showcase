import SwiftUI

// MARK: - ShowcaseStyle Extension

public extension ShowcaseLayoutStyle where Self == VerticalShowcaseLayoutStyle {
    /// A vertical showcase layout.
    static var vertical: Self { .init() }
}

/// The standard showcase style.
public struct VerticalShowcaseLayoutStyle: ShowcaseLayoutStyle {
    @Environment(\.nodeDepth) 
    private var depth

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            if depth > 0 {
                Divider().padding(.bottom)
            }

            configuration.indexList.padding(.bottom, 30)
            configuration.content
            configuration.children
        }
        .padding(depth == .zero ? .horizontal : [])
        .padding(depth == .zero ? [] : .vertical)
        .padding(depth > .zero ? .bottom : [], 20)
    }
}
