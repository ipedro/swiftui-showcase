import SwiftUI

// MARK: - ShowcaseStyle Extension

public extension ShowcaseLayoutStyle where Self == DefaultShowcaseLayoutStyle {
    /// A vertical showcase layout.
    static var automatic: DefaultShowcaseLayoutStyle {
        DefaultShowcaseLayoutStyle()
    }
}

/// The standard showcase style.
public struct DefaultShowcaseLayoutStyle: ShowcaseLayoutStyle {
    @Environment(\.nodeDepth) 
    private var depth

    public func makeBody(configuration: Configuration) -> some View {
        LazyVStack(alignment: .leading) {
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
