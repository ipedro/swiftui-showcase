//  Copyright (c) 2024 Pedro Almeida
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import SwiftUI

struct ShowcaseChapter: View {
    var data: Chapter

    var body: some View {
        Section(
            content: content,
            header: header,
            footer: footer
        )
    }

    private func label(topic: Topic) -> some View {
        ShowcaseTopicLabel(
            data: topic,
            fallbackIcon: data.icon ?? data.icon
        )
        .equatable()
    }
    
    private func content() -> some View {
        OutlineGroup(data.topics, children: \.children) { item in
            NavigationLink(value: item, label: {
                label(topic: item)
            })
        }
    }

    private func header() -> some View {
        Text(data.title)
    }

    @ViewBuilder
    private func footer() -> some View {
        if let footer = data.description {
            Text(footer)
        }
    }
}
