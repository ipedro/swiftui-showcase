import SwiftUI

// MARK: - ShowcaseStyle Extension

public extension ShowcaseStyle where Self == ShowcaseStyleSystem {
    /// <#short overview of the system style#>
    static var system: Self {
        .init()
    }
}

// MARK: - ShowcaseStyleSystem

/// An example Showcase style to get you started
public struct ShowcaseStyleSystem: ShowcaseStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            
            configuration.topic
            
            if !configuration.subtopics.isEmpty {
                
                configuration.navigation
            
                Divider()
                
                ForEach(configuration.subtopics) { topic in
                    VStack(alignment: .leading) {
                        topic
                    }
                    .padding(.vertical)
                    
                    Divider()
                }
            }
        }
        .padding(.horizontal, configuration.level == .zero ? 20 : .zero)
        .padding(.vertical, configuration.level == .zero ? 0 : 24)
    }
}
