import SwiftUI
import SafariServices

public struct SectionLink: View, Identifiable {
    public var id: String { url.absoluteString }
    var name: String
    var url: URL
    
    init?(_ name: String, url: URL?) {
        guard let url = url else { return nil }
        self.name = name
        self.url = url
    }
    
    public var body: some View {
        Button {
            let safariController = SFSafariViewController(url: url)
            safariController.preferredControlTintColor = .label

            UIApplication
                .shared
                .firstKeyWindow?
                .rootViewController?
                .present(safariController, animated: true)
            
        } label: {
            HStack {
                Image(systemName: "safari")
                Text(name)
            }
        }
    }
}

extension UIApplication {
    var firstKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?
            .keyWindow
    }
}
