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
public struct ShowcasePreview: View {
    /// The style configuration for Preview.
    typealias Configuration = ShowcasePreviewStyleConfiguration
    
    /// The style for displaying the preview.
    @Environment(\.showcasePreviewStyle) private var style
    
    /// The data representing the preview.
    let data: Topic.Preview
    
    /// Initializes a Preview view with the specified preview data.
    /// - Parameter data: The data representing the preview (optional).
    init?(_ data: Topic.Preview?) {
        guard let data = data else { return nil }
        self.data = data
    }
    
    /// The configuration for the Preview view.
    var configuration: Configuration {
        .init(preview: data.content)
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

public struct ShowcasePreviewStyleConfiguration {
    /// The type-erased preview content.
    public let preview: AnyView
}

// MARK: - Preview

struct Preview_Previews: PreviewProvider {
    static let styles: [AnyShowcasePreviewStyle] = [
        .init(.paged)
    ]
    
    static var previews: some View {
        ForEach(0...styles.count - 1, id: \.self) { index in
            ShowcasePreview(.init {
                MockPreviews()
            })
        }
    }
}
