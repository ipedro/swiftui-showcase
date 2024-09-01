import SwiftUI
import WebKit

public struct ShowcaseEmbeds: View {
    var content: EquatableForEach<[Topic.Embed], ShowcaseEmbed>
    public var body: some View { content }
}

struct ShowcaseEmbed: View, Equatable {
    static func == (lhs: ShowcaseEmbed, rhs: ShowcaseEmbed) -> Bool {
        lhs.data.id == rhs.data.id
    }

    @State 
    private var height: CGFloat = 10 // Initial height, it will be adjusted later

    var data: Topic.Embed

    var body: some View {
        #if os(iOS)
        WebView(url: data.url, handler: data.navigationHandler, height: $height)
            .frame(height: max(data.minHeight ?? 0, height))
            .disabled(!data.isInteractionEnabled)
        #else
        EmptyView()
        #endif
    }
}

#if os(iOS)
private struct WebView: UIViewRepresentable {
    var url: URL
    var handler: (WKNavigationAction) -> WKNavigationActionPolicy
    @Binding var height: CGFloat

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false  // Disable scrolling of the WKWebView
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, handler: handler)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        var handler: (WKNavigationAction) -> WKNavigationActionPolicy

        init(_ parent: WebView, handler: @escaping (_ navigationAction: WKNavigationAction) -> WKNavigationActionPolicy) {
            self.parent = parent
            self.handler = handler
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(handler(navigationAction))
        }

        // Add any WKNavigationDelegate methods if needed
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.evaluateJavaScript("document.documentElement.scrollHeight") { (height, error) in
                guard let height = height as? CGFloat else { return }

                DispatchQueue.main.async {
                    webView.scrollView.contentSize = CGSize(width: webView.bounds.width, height: height)
                    webView.setNeedsLayout()
                    self.parent.height = height
                }
            }
        }
    }
}
#endif
