import SwiftUI
import WebKit

struct ShowcaseEmbed: View {
    @State private var height: CGFloat = 10 // Initial height, it will be adjusted later
    var data: Topic.Embed

    var body: some View {
        WebView(url: data.url, handler: data.navigationHandler, height: $height)
            .frame(height: max(data.minHeight ?? 0, height))
            .disabled(!data.isInteractionEnabled)
    }
}

