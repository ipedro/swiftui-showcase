import SwiftUI

/// A view that displays a list of showcases organized into sections.
public struct ShowcaseList<Icon: View>: View {
    /// The data representing showcase sections.
    let data: [ShowcaseSection]
    
    /// The icon to be displayed next to each showcase item in the list.
    let icon: Icon
    
    /// Initializes a showcase list with the specified data and optional icon.
    /// - Parameters:
    ///   - data: The data representing showcase sections.
    ///   - icon: A closure that returns the icon view for each showcase item (optional).
    public init(
        _ data: [ShowcaseSection],
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.data = data
        self.icon = icon()
    }
    
    /// The body of the showcase list view.
    public var body: some View {
        List {
            ForEach(data) { section in
                Section(section.title) {
                    OutlineGroup(section.data, children: \.children) { item in
                        NavigationLink {
                            Showcase(item)
                        } label: {
                            Label {
                                Text(item.content.title)
                            } icon: {
                                icon
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ShowcaseList_Previews: PreviewProvider {
    static var list: [ShowcaseElement] = [
        .accordion,
        .card
    ]
    
    static var previews: some View {
        NavigationView {
            ShowcaseList([
                .init("List", elements: list)
            ])
        }
    }
}
