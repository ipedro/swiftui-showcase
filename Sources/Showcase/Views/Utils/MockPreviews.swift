import SwiftUI

struct MockPreviews: View {
    var colors: [SwiftUI.Color] = [
        .accentColor,
        .primary,
        .teal,
        .indigo,
        .purple,
        .green,
        .mint
    ]
    
    var body: some View {
        ForEach(colors, id: \.self) { color in
            VStack {
                Image(systemName: "swift")
                Text("Placeholder")
            }
            .foregroundColor(color)
            .redacted(reason: .placeholder)
        }
    }
}
