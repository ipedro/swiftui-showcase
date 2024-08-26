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

public struct ShowcaseTopic: View, Equatable {
    public static func == (lhs: ShowcaseTopic, rhs: ShowcaseTopic) -> Bool {
        lhs.data.id == rhs.data.id
    }

    @Environment(\.nodeDepth)
    private var depth

    let data: Topic
    
    public init(_ data: Topic) {
        self.data = data
    }
    
    public var body: some View {
        ShowcaseLayout(configuration)
    }

    private var contentConfiguration: ShowcaseContentConfiguration {
        ShowcaseContentConfiguration(
            id: data.id, 
            isEmpty: data.description.isEmpty,
            title: depth > 0 ? Text(data.title) : nil,
            description: data.description.isEmpty ? nil : Text(data.description),
            preview: preview(),
            links: ShowcaseLinks(data: data.links),
            embeds: ShowcaseEmbeds(data: data.embeds),
            codeBlocks: ShowcaseCodeBlocks(data: data.codeBlocks)
        )
    }

    private func preview() -> ShowcasePreview? {
        guard let previews = data.previews?() else { return nil }
        return ShowcasePreview(
            id: data.id,
            content: previews,
            label: Text(optional: data.previewTitle)
        )
    }

    private var configuration: ShowcaseLayoutConfiguration {
        ShowcaseLayoutConfiguration(
            children: ShowcaseTopics(data: data.children),
            indexList: depth == 0 && !data.allChildren.isEmpty ? ShowcaseIndexList(data: data) : nil,
            configuration: contentConfiguration
        )
    }
}
