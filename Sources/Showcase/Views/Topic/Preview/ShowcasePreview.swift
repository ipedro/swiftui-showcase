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
    /// The style for displaying the preview content.
    @Environment(\.previewStyle) 
    private var style

    /// The data representing the preview.
    private let configuration: ShowcasePreviewStyleConfiguration

    /// Initializes a Preview view with the specified previews data.
    /// - Parameter data: The data representing the previews (optional).
    init?(_ data: Topic) {
        guard let preview = data.previews else { return nil }
        configuration = ShowcasePreviewStyleConfiguration(
            title: Text(optional: LocalizedStringKey(optional: data.previewTitle)),
            content: .init(preview)
        )
    }

    /// Initializes a Preview view with an existing configuration.
    public init(_ configuration: ShowcasePreviewStyleConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        AnyView(style.resolve(configuration: configuration))
    }
}

// MARK: - Configuration

public struct ShowcasePreviewStyleConfiguration {
    let title: Text?

    public typealias Content = AnyView
    /// The type-erased preview content.
    public let content: Content
}
