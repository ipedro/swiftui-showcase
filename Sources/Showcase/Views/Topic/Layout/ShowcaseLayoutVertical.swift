import SwiftUI

// MARK: - ShowcaseStyle Extension

public extension ShowcaseLayoutStyle where Self == ShowcaseLayoutVertical {
    /// A vertical showcase layout.
    static var vertical: Self {
        .init()
    }
}
/// The standard showcase style.
public struct ShowcaseLayoutVertical: ShowcaseLayoutStyle {
    public func makeBody(configuration: Configuration) -> some View {
        ContentView(configuration: configuration)
    }
    
    private struct ContentView: View {
        @Environment(\.nodeDepth) private var depth
        var configuration: Configuration
        
        var body: some View {
            VStack(alignment: .leading) {
                
                configuration.content
                
                if let index = configuration.index {
                    index.padding(.vertical)
                    Divider()
                }
                
                configuration.children
                    .padding(.vertical)
                    .padding(.bottom)
                    .overlay(alignment: .bottom) {
                        Divider()
                    }
                
            }
            .padding(depth == .zero ? .horizontal : [])
            .padding(depth == .zero ? [] : .vertical)
            .toolbar {
                ToolbarItem {
                    configuration.index
                        .showcaseIndexStyle(.menu)
                }
            }
        }
    }
}
