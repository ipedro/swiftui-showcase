//  Copyright (c) 2023 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import SwiftUI

extension ShowcaseContentStyle where Self == ShowcaseContentVertical {
    /// A vertical content style.
    static var vertical: Self { .init() }
}

/// A vertical content style.
public struct ShowcaseContentVertical: ShowcaseContentStyle {
    
    public func makeBody(configuration: Configuration) -> some View {
        ContentView(configuration: configuration)
    }
    
    private struct ContentView: View {
        @Environment(\.nodeDepth) private var depth
        var configuration: Configuration
        
        var body: some View {
            VStack(alignment: .leading, spacing: 30) {
                // Display the title with appropriate styling based on the node depth.
                configuration.title.font(.system(titleStyle))
                
                // If there are external links, display them horizontally.
                if let links = configuration.links {
                    LazyHStack {
                        links
                    }
                }
                
                // Display previews, description, and code blocks with appropriate styling.
                configuration.preview
                
                configuration.description
                
                configuration.codeBlocks
                    .padding(.top)
            }
        }
        
        /// Determines the title font style based on the node depth.
        /// - Parameter depth: The node depth.
        /// - Returns: The font style for the title.
        var titleStyle: SwiftUI.Font.TextStyle {
            switch depth {
            case 0: return .largeTitle
            case 1: return .title
            case 2: return .title2
            default: return .title3
            }
        }
    }
}
