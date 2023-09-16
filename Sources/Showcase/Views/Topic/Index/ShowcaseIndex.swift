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
    let configuration: Configuration
    
    /// Initializes a ShowcaseIndex view with the specified configuration.
    /// - Parameter configuration: The configuration for the ShowcaseIndex view.
    init(configuration: Configuration) {
        self.configuration = configuration
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
        let data: [Topic]
        
        let impact = UIImpactFeedbackGenerator(style: .light)
        
        /// Initializes a label with the specified data and scroll view proxy.
        /// - Parameters:
        ///   - data: The data representing showcase topics.
        init?(data: [Topic]?) {
            guard let data = data, data.count > 1 else { return nil }
            self.data = data
        }
        
        /// The body of the label view.
        public var body: some View {
            if let scrollView = scrollView {
                ForEach(data) { item in
                    Button(item.title) {
                        impact.impactOccurred()
                        withAnimation {
                            scrollView.scrollTo(item.id, anchor: .top)
                        }
                    }
                }
                .onAppear {
                    impact.prepare()
                }
            }
        }
    }
}

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
            ShowcaseIndex(
                configuration: .init(
                    label: .init(data: [
                        .staticCard,
                        .navigationalCard,
                        .selectableCard,
                        .mockAccordion
                    ])
                )
            )
            .showcaseIndexStyle(styles[index])
        }
    }
}
