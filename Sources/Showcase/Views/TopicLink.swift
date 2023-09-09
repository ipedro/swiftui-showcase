import SwiftUI
import SafariServices

struct TopicLink: View {
    var name: String
    var url: URL
    
    init?(_ name: String, url: URL?) {
        guard let url = url else { return nil }
        self.name = name
        self.url = url
    }
    
    var body: some View {
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
