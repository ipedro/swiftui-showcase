import SwiftUI
import SafariServices

/// A view that displays an external link to a website in a Safari view controller.
struct ShowcaseExternalLink: View {
    /// The style environment variable for displaying external links.
    @Environment(\.externalLinkStyle) private var style
    
    /// The data representing the external link.
    let data: ShowcaseElement.ExternalLink
    
    var body: some View {
        Button {
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
    }
}

// MARK: - Default Style

public extension ShowcaseExternalLinkStyle where Self == ShowcaseExternalLinkStyleDefault {
    /// The default style for showcasing external links.
    static var standard: Self { .init() }
}

/// The default style for showcasing external links.
public struct ShowcaseExternalLinkStyleDefault: ShowcaseExternalLinkStyle {
    public func makeBody(configuration: Configuration) -> some View {
        BorderedButtonStyle().makeBody(configuration: configuration)
    }
}
