// Copyright (c) 2024 Pedro Almeida
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

import Foundation
import SwiftUI

struct ShowcaseChapters: View {
    @Binding
    var searchQuery: String
    var data: [Chapter]
    @State
    private var isExpanded = [Chapter.ID: Bool]()

    private var chapters: [Chapter] {
        let searchQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchQuery.isEmpty { return data }
        let result = data.search(searchQuery)
        return result
    }

    var body: some View {
        ForEach(chapters) { chapter in
            ShowcaseChapter(
                topics: chapter.topics,
                title: chapter.title,
                icon: chapter.icon,
                description: chapter.description, 
                isExpanded: .init(get: {
                    isExpanded[chapter.id, default: true]
                }, set: { newValue in
                    isExpanded[chapter.id] = newValue
                })
            )
        }
    }
}
