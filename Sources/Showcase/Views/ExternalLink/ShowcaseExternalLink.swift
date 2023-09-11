import SwiftUI
import SwiftUI
import SafariServices

struct ShowcaseExternalLink: View {
    @Environment(\.externalLinkStyle) private var style
    let data: ShowcaseItem.ExternalLink
    
    init(_ data: ShowcaseItem.ExternalLink) {
        self.data = data
    }
    
    var body: some View {
        Button {
            let safariController = SFSafariViewController(url: data.url)
            safariController.preferredControlTintColor = .label

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

extension ShowcaseExternalLinkStyle where Self == ShowcaseExternalLinkStyleDefault {
    static var standard: Self { .init() }
}

struct ShowcaseExternalLinkStyleDefault: ShowcaseExternalLinkStyle {
    func makeBody(configuration: Configuration) -> some View {
        BorderedButtonStyle().makeBody(configuration: configuration)
    }
}
