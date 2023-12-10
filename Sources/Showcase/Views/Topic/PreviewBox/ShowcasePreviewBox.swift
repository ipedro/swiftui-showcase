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
public struct ShowcasePreviewBox: View {
    /// The style for displaying the preview content.
    @Environment(\.previewContentStyle) 
    private var contentStyle
    
    /// The style for displaying the preview box.
    @Environment(\.previewBoxStyle)
    private var boxStyle

    /// The data representing the preview.
    private let configuration: ShowcasePreviewContentStyleConfiguration

    /// Initializes a Preview view with the specified previews data.
    /// - Parameter data: The data representing the previews (optional).
    init?(_ data: Topic) {
        guard let preview = data.previews else { return nil }
        self.configuration = .init(title: data.previewTitle, content: .init(preview))
    }

    public init(_ configuration: ShowcasePreviewContentStyleConfiguration) {
        self.configuration = configuration
    }

    public var body: some View {
        GroupBox(content: content, label: label).groupBoxStyle(AnyGroupBoxStyle(boxStyle))
    }

    private func content() -> some View {
        AnyView(contentStyle.resolve(configuration: configuration))
    }

    @ViewBuilder
    private func label() -> some View {
        if let title = configuration.title { Text(title) }
    }
}

// MARK: - Configuration

public struct ShowcasePreviewContentStyleConfiguration {
    let title: String?

    public typealias Content = AnyView
    /// The type-erased preview content.
    public let content: Content
}
