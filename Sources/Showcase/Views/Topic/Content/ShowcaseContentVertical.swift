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
            LazyVStack(alignment: .leading, spacing: 30) {
                configuration.title.font(.system(titleStyle))
                
                if let links = configuration.links {
                    LazyHStack {
                        links
                    }
                }
                
                configuration.preview
                    .padding(.bottom)
                
                configuration.description
                    .padding(.bottom)
                
                configuration.embeds
                
                configuration.codeBlocks
            }
        }
        
        var titleStyle: SwiftUI.Font.TextStyle {
            switch depth {
            case 0: return .largeTitle
            case 1: return .title
            case 2: return .title2
            case 3: return .title3
            default: return .headline
            }
        }
        
        var bodyStyle: SwiftUI.Font.TextStyle {
            switch depth {
            case 2: return .callout
            case 3: return .footnote
            default: return .body
            }
        }
    }
}
