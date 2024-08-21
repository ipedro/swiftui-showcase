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
import Engine
import EngineMacros

/// A view that displays previews of showcase topics.
@StyledView
public struct ShowcasePreview: StyledView, Equatable {
    public static func == (lhs: ShowcasePreview, rhs: ShowcasePreview) -> Bool {
        lhs.id == rhs.id
    }
    
    public var label: Optional<Text>
    public var previews: AnyView
    public var id: UUID

    init?(_ data: Topic) {
        guard let previews = data.previews() else { return nil }
        self.previews = previews
        self.label = Text(data.previewTitle ?? "")
        self.id = data.id
    }

    public var body: some View {
        previews
    }
}

extension View {
    /// Sets the style for ``ShowcaseDocument`` within this view to a Showcase style with a
    /// custom appearance and custom interaction behavior.
    ///
    /// Use this modifier to set a specific style for ``ShowcaseDocument`` instances
    /// within a view:
    ///
    ///     ShowcaseNavigationStack().showcasePreviewStyle(MyCustomStyle())
    ///
    public func showcasePreviewStyle<S: ShowcasePreviewStyle>(_ style: S) -> some View {
        modifier(ShowcasePreviewStyleModifier(style))
    }
}
