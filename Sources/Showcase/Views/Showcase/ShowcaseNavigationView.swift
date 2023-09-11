import SwiftUI

public struct ShowcaseNavigationView<Icon: View>: View {
    var data: ShowcaseLibrary
    var icon: Icon
    
    public init(
        _ data: ShowcaseLibrary,
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.data = data
        self.icon = icon()
    }
    
    public var body: some View {
        NavigationView {
            ShowcaseList(data.sections) { icon }
                .navigationTitle(data.title)
        }
    }
}

// MARK: - Previews

struct ShowcaseNavigationView_Previews: PreviewProvider {
    static var list: [ShowcaseItem] = [
        .card,
        .accordion
    ]

    static var previews: some View {
        ShowcaseNavigationView(
            .init(
                "Library",
                sections: [
                    .init("Mock", data: list)
                ]
            )
        )
    }
}
