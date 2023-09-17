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
    var data: Topic
    
    /// The configuration for the ShowcaseIndexList view.
    var configuration: Configuration {
        .init { padding, icon in
            .init(
                data: data,
                padding: padding,
                icon: icon)
        }
    }
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Configuration

public struct ShowcaseIndexListStyleConfiguration {
    public let label: (_ padding: CGFloat, _ icon: any View) -> Label?
    
    public struct Label: View {
        @Environment(\.scrollView) private var scrollView
        @Environment(\.nodeDepth) private var depth
        let data: Topic
        let icon: AnyView
        let padding: CGFloat
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        
        init?(
            data: Topic,
            padding: CGFloat,
            icon: any View
        ) {
            self.data = data
            self.icon = .init(icon)
            self.padding = padding
        }
        
        public var body: some View {
            if scrollView != nil {
                button(data)
                
                if let children = data.children?.sorted() {
                    ForEach(children) { topic in
                        ShowcaseIndexList(data: topic)
                    }
                    .nodeDepth(depth + 1)
                }
            }
        }
        
        private func button(_ topic: Topic) -> some View {
            Button {
                scrollTo(topic)
            } label: {
                HStack(alignment: .top) {
                    icon
                    Text(topic.title)
                    Spacer()
                }
            }
            .padding(.leading, padding * CGFloat(depth))
        }
        
        private func scrollTo(_ topic: Topic) {
            impact.impactOccurred()
            withAnimation {
                scrollView?.scrollTo(topic.id, anchor: .top)
            }
        }
    }
}

// MARK: - Previews

struct ShowcaseIndexList_Previews: PreviewProvider {
    static var previews: some View {
        ScrollViewReader {
            ShowcaseIndexList(data: .mockButton)
                .scrollViewProxy($0)
        }
    }
}
