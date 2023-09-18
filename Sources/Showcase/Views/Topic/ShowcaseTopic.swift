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

public struct ShowcaseTopic: View {
    @Environment(\.nodeDepth) private var depth
    
    let data: Topic
    
    public init(_ data: Topic) {
        self.data = data
    }
    
    public var body: some View {
        ShowcaseLayout(configuration: configuration)
            .id(data.id)
    }
    
    var description: Text? {
        data.description.isEmpty ? nil : Text(data.description)
    }
    
    var title: Text? {
        depth > 0 ? Text(data.title) : nil
    }
    
    var showIndexList: Bool {
        depth == 0 && data.children != nil
    }
    
    var configuration: ShowcaseLayout.Configuration {
        .init(
            children: .init(data: data.children),
            content: .init(
                id: data.id,
                configuration: .init(
                    title: title,
                    description: description,
                    preview: .init(data.preview),
                    links: .init(data: data.links),
                    codeBlocks: .init(data: data.codeBlocks)
                )),
            indexList: showIndexList ? .init(data: data) : nil
        )
    }
}

// MARK: - Previews

struct Showcase_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ScrollViewReader {
                ScrollView {
                    ShowcaseTopic(.mockAccordion)
                }
                .scrollViewProxy($0)
            }
            .toolbar {
                ShowcaseIndexMenu(.mockAccordion)
            }
        }
    }
}
