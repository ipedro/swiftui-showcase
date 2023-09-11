import SwiftUI

public struct ShowcaseList<Icon: View>: View {
    let data: [ShowcaseItem]
    let icon: Icon
    let maxWidth: CGFloat
    
    public init(
        _ data: [ShowcaseItem],
        maxWidth: CGFloat = 600,
        @ViewBuilder icon: () -> Icon
    ) {
        self.data = data
        self.maxWidth = maxWidth
        self.icon = icon()
    }
    
    public var body: some View {
        List(data, children: \.children) { item in
            NavigationLink {
                HStack(spacing: .zero) {
                    Showcase(item).frame(maxWidth: maxWidth)
                    Spacer(minLength: 0)
                }
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
        }
    }
}
