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
    @Environment(\.indexListStyle) private var style

    typealias Configuration = ShowcaseIndexListStyleConfiguration
    private let configuration: Configuration

    init?(_ data: Topic) {
        configuration = .init { padding, icon in
            .init(
                data: data,
                icon: .init(icon),
                padding: padding)
        }
    }

    public init(configuration: ShowcaseIndexListStyleConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        AnyView(style.resolve(configuration: configuration))
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

        private var topics: [Topic] {
            data.children ?? []
        }

        public var body: some View {
            if depth > 0 {
                Item(data: data, icon: icon).padding(.leading, depthPadding)
            }

            ForEach(topics) { topic in
                ShowcaseIndexList(topic).nodeDepth(depth + 1)
            }
        }
    }
    
    struct Item: View {
        @Environment(\.scrollView) private var scrollView
        
        #if canImport(UIKit)
        let impact = UIImpactFeedbackGenerator(style: .light)
        #endif

        var data: Topic
        let icon: AnyView?
        
        var body: some View {
            Button {
                #if canImport(UIKit)
                impact.impactOccurred()
                #endif

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
