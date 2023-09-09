import SwiftUI

struct Previews<V: View>: View {
    var content: V
    
    init?(content: V?) {
        guard let content = content else { return nil }
        self.content = content
    }
    
    var body: some View {
        GroupBox {
            TabView {
                content
            }
            .tabViewStyle(.page)
        } label: {
            Text("Previews")
        }
        .padding(.vertical)
        .onAppear(perform: setupPageControl)
    }
    
    func setupPageControl() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .label
        UIPageControl.appearance().pageIndicatorTintColor = .label.withAlphaComponent(0.3)
    }
}
