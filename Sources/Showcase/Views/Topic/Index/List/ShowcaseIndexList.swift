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

public struct ShowcaseIndexList: View {
    typealias Configuration = ShowcaseIndexListStyleConfiguration
    @Environment(\.indexListStyle) private var style
    var configuration: Configuration
    
    init?(_ data: Topic) {
        configuration = .init { padding, icon in
            .init(
                data: data,
                icon: .init(icon),
                padding: padding)
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
        @Environment(\.nodeDepth) private var depth
        var depthPadding: CGFloat { CGFloat(depth) * padding }
        let data: Topic
        let icon: AnyView
        let padding: CGFloat

        public var body: some View {
            Item(
                data: data,
                icon: depth > 0 ? icon : nil)
            .padding(.leading, depthPadding)
            
            if let children = data.children {
                ForEach(children) { topic in
                    ShowcaseIndexList(topic)
                        .nodeDepth(depth + 1)
                }
            }
        }
    }
    
    struct Item: View {
        @Environment(\.scrollView) private var scrollView
        let impact = UIImpactFeedbackGenerator(style: .light)
        var data: Topic
        let icon: AnyView?
        
        var body: some View {
            Button {
                impact.impactOccurred()
                withAnimation {
                    scrollView?.scrollTo(data.id, anchor: .top)
                }
            } label: {
                HStack(alignment: .top) {
                    icon
                    Text(data.title)
                    Spacer()
                }
            }
            .accessibilityAddTraits(.isLink)
        }
    }
}

// MARK: - Previews

struct ShowcaseIndexList_Previews: PreviewProvider {
    static var previews: some View {
        ShowcaseIndexList(.mockButton)
    }
}