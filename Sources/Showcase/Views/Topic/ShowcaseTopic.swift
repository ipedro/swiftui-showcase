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
            description: description(),
            previews: previews(),
            links: links(),
            embeds: embeds(),
            codeBlocks: codeBlocks()
        )
    }

    private func description() -> Text? {
        data.description.isEmpty ? nil : Text(data.description)
    }

    private func links() -> ShowcaseLinks? {
        if let links = EquatableForEach(
            data: data.links,
            content: ShowcaseLink.init(data:)
        ) {
            ShowcaseLinks(content: links)
        } else {
            nil
        }
    }

    private func embeds() -> ShowcaseEmbeds? {
        if let embeds = EquatableForEach(
            data: data.embeds,
            content: ShowcaseEmbed.init(data:)
        ) {
            ShowcaseEmbeds(content: embeds)
        } else {
            nil
        }
    }

    private func codeBlocks() -> ShowcaseCodeBlocks? {
        if let codeBlocks = EquatableForEach(
            data: data.codeBlocks,
            content: ShowcaseCodeBlock.init(data:)
        ) {
            ShowcaseCodeBlocks(content: codeBlocks)
        } else {
            nil
        }
    }

    private func previews() -> ShowcasePreviews? {
        if let previews = EquatableForEach(
            data: data.previews,
            content: ShowcasePreview.init(data:)
        ) {
            ShowcasePreviews(content: previews)
        } else {
            nil
        }
    }

    private var configuration: ShowcaseLayoutConfiguration {
        ShowcaseLayoutConfiguration(
            children: ShowcaseTopics(data: data.children),
            indexList: indexList(),
            configuration: contentConfiguration
        )
    }

    private var showIndexList: Bool {
        depth == 0 && data.children != nil
    }
    private func indexList() -> ShowcaseIndexList? {
        if depth == 0, let children = data.children {
            ShowcaseIndexList(data: children)
        } else {
            nil
        }
    }
}
