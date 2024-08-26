import SwiftUI

public struct ShowcaseEmptyIndexList: ShowcaseIndexListStyle {
    public func makeBody(configuration: ShowcaseIndexListConfiguration) -> some View {
        EmptyView()
    }
}

public extension ShowcaseIndexListStyle where Self == ShowcaseEmptyIndexList {
    static var none: Self { .init() }
}
