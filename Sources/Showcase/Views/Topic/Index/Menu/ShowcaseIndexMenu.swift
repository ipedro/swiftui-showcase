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

public struct ShowcaseIndexMenu: View {
    typealias Configuration = ShowcaseIndexMenuStyleConfiguration
    
    @Environment(\.indexMenuStyle) private var style
    
    var configuration: Configuration
    
    init(_ data: Topic) {
        configuration = .init(label: .init(data: data))
    }
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Configuration

public struct ShowcaseIndexMenuStyleConfiguration {
    public let label: Label?
    
    public struct Label: View {
        @Environment(\.scrollView) private var scrollView
        let data: Topic
        let impact = UIImpactFeedbackGenerator(style: .light)
        
        public var body: some View {
            button(data)
            
            Divider()
            
            let children = data.allChildren
            
            if !children.isEmpty {
                ForEach(children, content: button)
            }
        }
        
        private func button(_ data: Topic) -> some View {
            Button(data.title) {
                impact.impactOccurred()
                withAnimation {
                    scrollView?.scrollTo(data.id, anchor: .top)
                }
            }
        }
    }
}

// MARK: - Previews

struct ShowcaseIndexMenu_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseIndexMenu(.mockButton)
    }
}
