import SwiftUI

public struct ShowcaseList<Icon: View>: View {
    var data: [ShowcaseItem]
    var icon: Icon
    
    public init(_ data: [ShowcaseItem], @ViewBuilder icon: () -> Icon) {
        self.data = data
        self.icon = icon()
    }
    
    public var body: some View {
        List(data, children: \.children) { item in
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

struct ShowcaseList_Previews: PreviewProvider {
    static var list: [ShowcaseItem] = [
        .accordion,
        .card
    ]
    
    static var previews: some View {
        NavigationView {
            ShowcaseList(list) {
                Image(systemName: "swift")
                    .foregroundColor(.orange)
            }
            .navigationTitle("Components")
            //.listStyle(.sidebar)
        }
    }
}