import SwiftUI

public struct ShowcaseEmptyIndexMenu: ShowcaseIndexMenuStyle {
    public func makeBody(configuration: ShowcaseIndexMenuConfiguration) -> some View {
        EmptyView()
    }
}

public extension ShowcaseIndexMenuStyle where Self == ShowcaseEmptyIndexMenu {
    static var none: Self { .init() }
}
