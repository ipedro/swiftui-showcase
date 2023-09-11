import SwiftUI

struct PassthroughButtonStyle<C: View>: PrimitiveButtonStyle {
    @ViewBuilder var content: (_ button: Configuration) -> C
    
    func makeBody(configuration: Configuration) -> some View {
        content(configuration)
    }
}
