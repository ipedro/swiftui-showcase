import SwiftUI

struct MockPreviews: View {
    var body: some View {
        ForEach(0...5, id: \.self) { _ in
            VStack {
                Image(systemName: "swift")
                Text("Placeholder")
            }
            .redacted(reason: .placeholder)
        }
    }
}
