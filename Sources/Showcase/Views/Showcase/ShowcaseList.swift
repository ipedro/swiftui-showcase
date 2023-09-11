import SwiftUI

public struct ShowcaseList<Icon: View>: View {
    let data: [ShowcaseSection]
    let icon: Icon
    
    public init(
        _ data: [ShowcaseSection],
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.data = data
        self.icon = icon()
    }
    
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
