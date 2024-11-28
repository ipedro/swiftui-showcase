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

// MARK: - View Extension

extension View {
    /// Sets the style for `ShowcaseDocument` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for `ShowcaseDocument` instances
    /// within a view:
    ///
    ///     ShowcaseNavigationStack()
    ///         .showcaseLinkStyle(MyCustomStyle())
    ///
    /// - Parameter style: The link style
    /// - Returns: A copy of the view with the link style applied.
    public func showcaseLinkStyle<S: ButtonStyle>(_ style: S) -> some View {
        environment(\.linkStyle, .init(style))
    }
}

public struct ShowcaseLinks: View {
    var content: EquatableForEach<[Topic.Link], Topic.Link.ID, ShowcaseLink>
    public var body: some View { content }
}

/// A view that displays an external link to a website in a Safari view controller.
struct ShowcaseLink: View, Equatable {
    static func == (lhs: ShowcaseLink, rhs: ShowcaseLink) -> Bool {
        lhs.data.id == rhs.data.id
    }

    /// The style environment variable for displaying external links.
    @Environment(\.linkStyle) 
    private var style
    @Environment(\.controlSize) private var controlSize

    /// The data representing the external link.
    let data: Topic.Link

    #if canImport(UIKit)
    let impact = UISelectionFeedbackGenerator()
    #endif

    var body: some View {
        Button {
            #if canImport(UIKit)
            impact.selectionChanged()

            // Create a Safari view controller to open the external link.
            let safariController = SFSafariViewController(url: data.url)
            safariController.preferredControlTintColor = .label

            // Present the Safari view controller.
            UIApplication
                .shared
                .firstKeyWindow?
                .rootViewController?
                .present(safariController, animated: true)
            #endif
        } label: {
            HStack {
                Image(systemName: "safari")
                Text(data.name.description)
            }
        }
        .buttonStyle(style)
        .onAppear {
            #if canImport(UIKit)
            impact.prepare()
            #endif
        }
        
    }
}

// MARK: - Default Style

public extension ButtonStyle where Self == ShowcaseLinkStyleDefault {
    /// The default style for showcasing external links.
    static var standard: Self { .init() }
}

/// The default style for showcasing external links.
public struct ShowcaseLinkStyleDefault: ButtonStyle {
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 14)
        .background {
            RoundedRectangle(
                cornerRadius: 8,
                style: .continuous)
            .opacity(0.15)
        }
        .foregroundStyle(.tint)
        .scaleEffect(
            x: configuration.isPressed ? 0.97 : 1,
            y: configuration.isPressed ? 0.97 : 1,
            anchor: .center)
        .animation(.interactiveSpring(), value: configuration.isPressed)
    }
}

#if canImport(UIKit)
import UIKit

private extension UIApplication {
    var firstKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?
            .keyWindow
    }
}
#endif
