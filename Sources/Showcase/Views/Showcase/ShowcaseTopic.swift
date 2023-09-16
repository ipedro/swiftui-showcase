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

/// A view for showcasing code examples, descriptions, and links.
public struct ShowcaseTopic: View {
    /// The configuration type for the showcase view.
    typealias Configuration = ShowcaseStyleConfiguration
    
    /// The style environment for the showcase view.
    @Environment(\.showcaseStyle) private var style
    
    /// The topic to be displayed in the showcase.
    let data: Topic
    
    /// The nesting level of the topic.
    let level: Int
    
    /// Initializes a showcase view with the specified data and nesting level.
    /// - Parameters:
    ///   - data: The data to be displayed in the showcase.
    ///   - level: The nesting level of the showcase.
    private init(_ data: Topic, level: Int) {
        self.data = data
        self.level = level
    }
    
    /// Initializes a showcase view with the specified data at the root level.
    /// - Parameter data: The data to be displayed in the showcase.
    public init(_ data: Topic) {
        self.data = data
        self.level = .zero
    }
    
    /// Generates the showcase configuration based on the provided ScrollViewProxy.
    /// - Parameter scrollView: The ScrollViewProxy to interact with the ScrollView.
    /// - Returns: The showcase configuration.
    func configuration(
        _ scrollView: ScrollViewProxy
    ) -> Configuration {
        Configuration(
            children: ShowcaseChildren(
                data: data.children,
                level: level + 1,
                parentID: data.id,
                scrollView: scrollView
            ),
            content: ShowcaseContent(
                data: data,
                level: level),
            index: ShowcaseIndex(
                configuration: .init(
                    label: .init(
                        data: data.children,
                        scrollView: scrollView))),
            level: level
        )
    }
    
    public var body: some View {
        ScrollViewReader { scrollView in
            let configuration = configuration(scrollView)
            
            ScrollView {
                style.makeBody(configuration: configuration)
            }
            .navigationTitle(Text(data.title))
        }
    }
}

/// The configuration for a showcase view.
public struct ShowcaseStyleConfiguration {
    /// The children views within the showcase.
    public let children: ShowcaseChildren?
    
    /// The content view of the showcase.
    public let content: ShowcaseContent
    
    /// The index view for navigating within the showcase.
    public let index: ShowcaseIndex?
    
    /// The nesting level of the showcase.
    public let level: Int
    
}

// MARK: - ShowcaseStyle Extension

public extension ShowcaseStyle where Self == ShowcaseStyleStandard {
    /// The standard showcase style.
    static var standard: Self {
        .init()
    }
}

/// The standard showcase style.
public struct ShowcaseStyleStandard: ShowcaseStyle {
    /// Generates the body of the showcase based on the provided configuration.
    /// - Parameter configuration: The showcase configuration.
    /// - Returns: The body of the showcase.
    public func makeBody(configuration: Configuration) -> some View {
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
        .padding(configuration.level == .zero ? .horizontal : [])
        .padding(configuration.level == .zero ? [] : .vertical)
        .toolbar {
            ToolbarItem {
                configuration.index
                    .showcaseIndexStyle(.menu)
            }
        }
    }
}

struct Showcase_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowcaseTopic(
                Topic(
                    title: "Button",
                    description: {
"""
A button initiates an instantaneous action.

A stylized representation of two horizontally aligned buttons. The image is tinted red to subtly reflect the red in the original six-color Apple logo.
Versatile and highly customizable, buttons give people simple, familiar ways to do tasks in your app.
"""
                    },
                    links: {
                        Topic.Link(" HIG", .init(string: "https://developer.apple.com/design/human-interface-guidelines/buttons"))
                    },
                    examples: {
                        Topic.CodeBlock {
"""
Button("I'm a bordered button") {
    // do something
}
.buttonStyle(.bordered)
"""
                        }
                    },
                    previews: .init {
                        Button("I'm a bordered button") {
                            // do something
                        }
                        .buttonStyle(.bordered)
                    }
                )
            )
        }
    }
}
