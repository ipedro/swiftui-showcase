// ShowcaseEmbed.swift
// Copyright (c) 2025 Pedro Almeida
// Created by Pedro Almeida on 11/8/25.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI
#if swift(>=5.10)
    @preconcurrency import WebKit
#else
    import WebKit
#endif

public struct ShowcaseEmbeds: View {
    var content: EquatableForEach<[Embed], Embed.ID, ShowcaseEmbed>
    public var body: some View { content }
}

struct ShowcaseEmbed: View, Equatable {
    static func == (lhs: ShowcaseEmbed, rhs: ShowcaseEmbed) -> Bool {
        lhs.data.id == rhs.data.id
    }

    @State
    private var height: CGFloat = 10 // Initial height, it will be adjusted later

    var data: Embed

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
            webView.scrollView.isScrollEnabled = false // Disable scrolling of the WKWebView
            return webView
        }

        func updateUIView(_ uiView: WKWebView, context _: Context) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self, handler: handler)
        }

        final class Coordinator: NSObject, WKNavigationDelegate {
            var parent: WebView
            var handler: (WKNavigationAction) -> WKNavigationActionPolicy

            init(_ parent: WebView, handler: @escaping (_ navigationAction: WKNavigationAction) -> WKNavigationActionPolicy) {
                self.parent = parent
                self.handler = handler
            }

            func webView(_: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
                decisionHandler(handler(navigationAction))
            }

            /// Add any WKNavigationDelegate methods if needed
            func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
                webView.evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] height, _ in
                    guard let self = self, let height = height as? CGFloat else { return }

                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        webView.scrollView.contentSize = CGSize(width: webView.bounds.width, height: height)
                        webView.setNeedsLayout()
                        self.parent.height = height
                    }
                }
            }
        }
    }
#endif
