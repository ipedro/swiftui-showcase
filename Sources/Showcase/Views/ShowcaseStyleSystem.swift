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
            
            configuration.label
            
            if !configuration.sections.isEmpty {
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(configuration.navigation) { button in
                            button
                        }
                    }
                }
                .padding(.vertical)
            
                Divider()
                
                ForEach(configuration.sections) { section in
                    VStack(alignment: .leading) {
                        section
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
