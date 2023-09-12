// Copyright (c) 2023 Pedro Almeida
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
import SafariServices

/// A view that displays an external link to a website in a Safari view controller.
struct ShowcaseExternalLink: View {
    /// The style environment variable for displaying external links.
    @Environment(\.externalLinkStyle) private var style
    
    /// The data representing the external link.
    let data: ShowcaseTopic.ExternalLink
    
    let impact = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button {
            impact.impactOccurred()
            
            // Create a Safari view controller to open the external link.
            let safariController = SFSafariViewController(url: data.url)
            safariController.preferredControlTintColor = .label

            // Present the Safari view controller.
            UIApplication
                .shared
                .firstKeyWindow?
                .rootViewController?
                .present(safariController, animated: true)
        } label: {
            HStack {
                Image(systemName: "safari")
                Text(data.title.description)
            }
        }
        .buttonStyle(
            PassthroughButtonStyle {
                style.makeBody(configuration: $0)
            }
        )
        .onAppear {
            impact.prepare()
        }
        
    }
}

// MARK: - Default Style

public extension ButtonStyle where Self == ShowcaseExternalLinkStyleDefault {
    /// The default style for showcasing external links.
    static var standard: Self { .init() }
}

/// The default style for showcasing external links.
public struct ShowcaseExternalLinkStyleDefault: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 14)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .opacity(0.12)
        }
        .foregroundStyle(.tint)
        .scaleEffect(
            x: configuration.isPressed ? 0.97 : 1,
            y: configuration.isPressed ? 0.97 : 1,
            anchor: .center)
        .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}
