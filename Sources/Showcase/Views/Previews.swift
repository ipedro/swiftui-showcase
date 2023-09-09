import SwiftUI

public struct Previews: View {
    var item: ShowcaseItem.Previews
    
    init?(_ item: ShowcaseItem.Previews?) {
        guard let item = item else { return nil }
        self.item = item
    }
    
    public var body: some View {
        GroupBox {
            TabView {
                item
                    .previews
                    .aspectRatio(item.aspectRatio, contentMode: .fit)
            }
            .tabViewStyle(.page)
        } label: {
            Text("Previews")
        }
        .padding(.vertical)
        .onAppear(perform: setupPageControl)
    }
    
    private func setupPageControl() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().pageIndicatorTintColor = .label.withAlphaComponent(0.3)
    }
}
