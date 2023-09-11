import SwiftUI

public struct ShowcaseList<Icon: View>: View {
    @State private var selection: ShowcaseItem.ID?
    let data: [ShowcaseItem]
    let icon: Icon
    
    public init(_ data: [ShowcaseItem], @ViewBuilder icon: () -> Icon) {
        self.data = data
        self.icon = icon()
        _selection = State(initialValue: data.first?.id)
    }
    
    public var body: some View {
        List(data, children: \.children, selection: $selection) { item in
            NavigationLink(
                isActive: .init(get: {
                    item.id == selection
                }, set: { newValue, transaction in
                    if newValue {
                        selection = item.id
                    }
                })) {
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

struct ShowcaseList_Previews: PreviewProvider {
    static var list: [ShowcaseItem] = [
        .accordion,
        .card
    ]
    
    static var previews: some View {
        NavigationView {
            ShowcaseList(list) {
                Image(systemName: "swift")
            }
            .navigationTitle("Components")
            .listStyle(.sidebar)

        }
    }
}
