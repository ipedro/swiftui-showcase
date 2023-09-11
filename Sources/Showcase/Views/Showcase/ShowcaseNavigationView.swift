import SwiftUI

/// A view that displays a navigation view containing a list of showcases organized into sections.
public struct ShowcaseNavigationView<Icon: View>: View {
    /// The data representing a showcase library.
    let data: ShowcaseLibrary
    
    /// The icon to be displayed next to each showcase item in the list.
    let icon: Icon
    
    /// Initializes a showcase navigation view with the specified data and optional icon.
    /// - Parameters:
    ///   - data: The data representing a showcase library.
    ///   - icon: A closure that returns the icon view for each showcase item (optional).
    public init(
        _ data: ShowcaseLibrary,
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.data = data
        self.icon = icon()
    }
    
    /// The body of the showcase navigation view.
    public var body: some View {
        NavigationView {
            ShowcaseList(data.sections) { icon }
                .navigationTitle(data.title)
        }
    }
}

// MARK: - Previews

struct ShowcaseNavigationView_Previews: PreviewProvider {
    static var list: [ShowcaseElement] = [
        .card,
        .accordion
    ]

    static var previews: some View {
        ShowcaseNavigationView(
            .init(
                "Library",
                sections: [
                    .init("Mock", elements: list)
                ]
            )
        )
    }
}
