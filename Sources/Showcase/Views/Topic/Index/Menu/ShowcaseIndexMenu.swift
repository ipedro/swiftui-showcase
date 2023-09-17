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

/// A view that displays navigation anchors to children elements within a Showcase view.
public struct ShowcaseIndexMenu: View {
    typealias Configuration = ShowcaseIndexMenuStyleConfiguration
    
    /// The style for displaying the index.
    @Environment(\.indexMenuStyle) private var style
    
    /// The configuration for the ShowcaseIndexMenu view.
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
    /// A type-erased collection of anchor buttons.
    public let label: Label?
    
    /// A type-erased collection of anchor buttons.
    public struct Label: View {
        @Environment(\.scrollView) private var scrollView
        
        /// The data representing showcase topics.
        let topic: Topic
        let children: [Topic]
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        
        init?(data: Topic) {
            guard
                let children = data.children,
                !children.isEmpty
            else { return nil }
            
            self.topic = data
            self.children = children
        }
        
        /// The body of the label view.
        public var body: some View {
            button(topic)
            
            if !topic.allChildren.isEmpty {
                Divider()
            }
            
            ForEach(children.sorted()) { topic in
                if topic.allChildren.isEmpty {
                    button(topic)
                } else {
                    ShowcaseIndexMenu(topic)
                        .showcaseIndexMenuStyle(
                            DefaultIndexMenuStyle {
                                button(topic)
                            }
                        )
                }
            }
        }
        
        private func button(_ topic: Topic) -> some View {
            Button(topic.title) {
                impact.impactOccurred()
                withAnimation {
                    scrollView?.scrollTo(topic.id, anchor: .top)
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
