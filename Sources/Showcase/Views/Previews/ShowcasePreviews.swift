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

/// A view that displays previews of showcase topics.
public struct ShowcasePreviews: View {
    /// The style configuration for ShowcasePreviews.
    typealias Configuration = ShowcasePreviewsStyleConfiguration
    
    /// The style for displaying the previews.
    @Environment(\.previewsStyle) private var style
    
    /// The data representing the previews.
    let data: ShowcaseTopic.Previews
    
    /// Initializes a ShowcasePreviews view with the specified previews data.
    /// - Parameter data: The data representing the previews (optional).
    init?(_ data: ShowcaseTopic.Previews?) {
        guard let data = data else { return nil }
        self.data = data
    }
    
    /// The configuration for the ShowcasePreviews view.
    var configuration: Configuration {
        .init(previews: data.content)
    }
    
    public var body: some View {
        GroupBox {
            style.makeBody(configuration: configuration)
                .frame(
                    minWidth: data.minWidth,
                    idealWidth: data.idealWidth,
                    maxWidth: data.maxWidth,
                    minHeight: data.minHeight,
                    idealHeight: data.idealHeight,
                    maxHeight: data.maxHeight,
                    alignment: data.alignment)
        } label: {
            if let title = data.title {
                Text(title)
            }
        }
    }
}

// MARK: - Configuration

public struct ShowcasePreviewsStyleConfiguration {
    /// The type-erased previews content.
    public typealias Previews = AnyView
    /// The previews content.
    public let previews: Previews
}

// MARK: - Styles

public extension ShowcasePreviewsStyle where Self == ShowcasePreviewsStylePaged {
    /// A paged style for ShowcasePreviews.
    static var paged: Self { .init() }
}

public struct ShowcasePreviewsStylePaged: ShowcasePreviewsStyle {
    public func makeBody(configuration: Configuration) -> some View {
        TabView {
            configuration.previews
                .offset(y: -30)
        }
        .offset(y: 20)
        .tabViewStyle(.page)
        .onAppear(perform: setupPageControl)
        .clipped()
    }
    
    /// Sets up the appearance of the page control for paged previews.
    private func setupPageControl() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .secondaryLabel
        UIPageControl.appearance().pageIndicatorTintColor = .label.withAlphaComponent(0.15)
    }
}

// MARK: - Previews

struct ShowcasePreviews_Previews: PreviewProvider {
    static let styles: [AnyShowcasePreviewsStyle] = [
        .init(.paged)
    ]
    
    static var previews: some View {
        ForEach(0...styles.count - 1, id: \.self) { index in
            ShowcasePreviews(.init {
                MockPreviews()
            })
        }
    }
}
