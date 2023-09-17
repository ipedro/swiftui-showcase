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
public struct ShowcaseIndexList: View {
    typealias Configuration = ShowcaseIndexListStyleConfiguration
    
    /// The style for displaying the index.
    @Environment(\.indexListStyle) private var style
    
    /// The configuration for the ShowcaseIndexList view.
    var configuration: Configuration
    
    init(_ data: Topic) {
        configuration = .init { icon in
            .init(data: data, icon: icon)
        }
    }
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Configuration

public struct ShowcaseIndexListStyleConfiguration {
    /// A type-erased collection of anchor buttons.
    public let label: (_ icon: any View) -> Label?
    
    /// A type-erased collection of anchor buttons.
    public struct Label: View {
        @Environment(\.nodeDepth) private var depth
        @Environment(\.scrollView) private var scrollView
        
        /// The data representing showcase topics.
        let topic: Topic
        let children: [Topic]
        let icon: AnyView
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        
        init?(data: Topic, icon: any View) {
            guard
                let children = data.children,
                !children.isEmpty
            else { return nil }
            
            self.topic = data
            self.children = children
            self.icon = .init(icon)
        }
        
        /// The body of the label view.
        public var body: some View {
            if depth == 0 {
                Button(topic.title) {
                    scrollTo(topic)
                }
            } else {
                button(topic)
            }
            
            ForEach(children.sorted()) { topic in
                if topic.allChildren.isEmpty {
                    button(topic)
                } else {
                    ShowcaseIndexList(topic)
                        .nodeDepth(depth + 1)
                }
            }
        }
        
        private func scrollTo(_ topic: Topic) {
            impact.impactOccurred()
            withAnimation {
                scrollView?.scrollTo(topic.id, anchor: .top)
            }
        }
        
        private func button(_ topic: Topic) -> some View {
            Button {
                scrollTo(topic)
            } label: {
                HStack(alignment: .center) {
                    icon.padding(.top, 1)
                    Text(topic.title)
                }
            }
        }
    }
}

// MARK: - Previews

struct ShowcaseIndexList_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseIndexList(.mockButton)
    }
}
