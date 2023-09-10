import SwiftUI

struct AnchorLink: View, Identifiable {
    let id: String
    let title: String
    let scrollView: ScrollViewProxy
    
    var body: some View {
        Button(title) {
            withAnimation(.spring()) {
                scrollView.scrollTo(id, anchor: .top)
            }
        }
    }
}
