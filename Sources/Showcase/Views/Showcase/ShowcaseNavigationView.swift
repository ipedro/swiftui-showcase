import SwiftUI

public struct ShowcaseNavigationView<Icon: View>: View {
    var data: [ShowcaseItem]
    var title: String
    var icon: Icon
    var maxWidth: CGFloat
    
    public init(
        _ data: [ShowcaseItem],
        title: String = "Components",
        @ViewBuilder icon: () -> Icon = { Image(systemName: "swift") },
        maxWidth: CGFloat = 600
    ) {
        self.data = data
        self.title = title
        self.icon = icon()
        self.maxWidth = maxWidth
    }
    
    public var body: some View {
        NavigationView {
            ShowcaseList(data, maxWidth: maxWidth) {
                icon
            }
            .navigationTitle(title)
            .listStyle(.sidebar)
        }
    }
}

// MARK: - Previews

struct ShowcaseNavigationView_Previews: PreviewProvider {
    static var list: [ShowcaseItem] = [
        .accordion,
        .card
    ]
    
    static var previews: some View {
        ShowcaseNavigationView(list)
    }
}
