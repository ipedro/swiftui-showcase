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
public struct ShowcaseIndex: View {
    typealias Configuration = ShowcaseIndexStyleConfiguration
    
    /// The style for displaying the index.
    @Environment(\.indexStyle) private var style
    
    /// The configuration for the ShowcaseIndex view.
    var configuration: Configuration
    
    init(_ data: Topic) {
        configuration = .init(label: .init(data: data))
    }
    
    public var body: some View {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - Configuration

public struct ShowcaseIndexStyleConfiguration {
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
            let children = data.allChildren
            guard !children.isEmpty else { return nil }
            self.topic = data
            self.children = children
        }
        
        /// The body of the label view.
        public var body: some View {
            button(topic)
            ForEach(children, content: button)
        }
        
//        private func buttons(_ topics: Topic) -> some View {
//            Group {
//                ForEach(Array(zip(topics.indices, topics)), id: \.0) { index, topic in
//                    button(topic)
//                }
//
//                Divider()
//            }
//        }
        
        private func button(_ topic: Topic) -> Button<Text> {
            Button(topic.title) {
                impact.impactOccurred()
                withAnimation {
                    scrollView?.scrollTo(topic.id, anchor: .top)
                }
            }
        }
    }
}

//extension Array: Identifiable where Element == Topic {
//    public var id: String {
//        map(\.id).joined(separator: ",")
//    }
//}

// MARK: - Styles

public extension ShowcaseIndexStyle where Self == ShowcaseIndexStyleBulletList {
    /// A bullet list style.
    static var bulletList: Self { .init() }
}

public extension ShowcaseIndexStyle where Self == ShowcaseIndexStyleMenu {
    /// A context menu style.
    static var menu: Self { .init() }
}

public struct ShowcaseIndexStyleBulletList: ShowcaseIndexStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
                .padding(.horizontal)
                .padding(.vertical, 2)
                .overlay(alignment: .leading) {
                    Circle()
                        .frame(width: 6)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 25)
        }
    }
}

public struct ShowcaseIndexStyleMenu: ShowcaseIndexStyle {
    /// The shape used for the menu style.
    private let shape = RoundedRectangle(
        cornerRadius: 8,
        style: .continuous)
    
    public func makeBody(configuration: Configuration) -> some View {
        if let label = configuration.label {
            Menu {
                label
            } label: {
                Image(systemName: "list.bullet")
                    .padding(5)
                    .mask { shape }
                    .background {
                        shape.opacity(0.1)
                    }
            }
        }
    }
}

// MARK: - Previews

struct ShowcaseIndex_Previews: PreviewProvider {
    static let styles: [AnyShowcaseIndexStyle] = [
        .init(.menu),
        .init(.bulletList)
    ]
    
    static var previews: some View {
        ForEach(0...styles.count - 1, id: \.self) { index in
            ShowcaseIndex(.mockAccordion)
                .showcaseIndexStyle(styles[index])
        }
    }
}
