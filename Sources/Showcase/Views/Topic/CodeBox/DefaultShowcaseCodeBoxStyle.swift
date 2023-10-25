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

extension ShowcaseCodeBoxStyle where Self == DefaultShowcaseCodeBoxStyle<BackgroundStyle> {
    /// The default style for code boxes.
    public static var automatic: Self {
        .init(background: .background)
    }
}

extension ShowcaseCodeBoxStyle where Self == DefaultShowcaseCodeBoxStyle<SwiftUI.Color> {
    /// The default style for code boxes.
    /// - Parameters:
    ///   - background: The style to render the background within the view.
    ///   - padding: An amount, given in points, to pad the content on all edges. If you set the value to nil, SwiftUI uses a platform-specific default amount. The default value of this parameter is `nil`.
    public static func automatic(background: SwiftUI.Color, padding: CGFloat? = nil) -> Self {
        .init(background: background, padding: padding)
    }
}

/// The default style for code boxes.
public struct DefaultShowcaseCodeBoxStyle<S: ShapeStyle>: ShowcaseCodeBoxStyle {
    var background: S
    var padding: CGFloat?

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            if #available(iOS 16.0, *) {
                configuration.label.bold()
            } else {
                configuration.label
            }
            Divider().opacity(0)
            configuration.content
        }
        .multilineTextAlignment(.leading)
        .padding(.all, padding)
        .background(content: backgroundView)
    }

    private func backgroundView() -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .foregroundStyle(background)
    }
}

#Preview {
    ShowcaseCodeBox(
        Topic.CodeBlock("Example", text: {
"""
HStack {
    Spacer()
    copyButton
}
"""
        }))
    .showcaseCodeBoxStyle(.automatic)
}
