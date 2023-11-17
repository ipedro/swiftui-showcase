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

/// A view that displays a list of showcases organized into chapters.
public struct ShowcaseDocument: View {
    /// The data representing showcase chapters.
    let document: Document

    /// Initializes a showcase list with the specified data and optional icon.
    /// - Parameters:
    ///   - document: The document representing showcase chapters.
    public init(_ document: Document) {
        self.document = document
    }
    
    public var body: some View {
        NavigationView {
            List {
                description()
                ForEach(document.chapters, content: section)
            }
            .navigationTitle(document.title)
        }
        .previewDisplayName(document.title)
    }
    
    @ViewBuilder 
    func description() -> some View {
        if let description = document.description {
            Section {
                Text(description)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }
    
    func section(_ chapter: Chapter) -> some View {
        Section {
            outlineGroup(chapter)
        } header: {
            Text(chapter.title)
        } footer: {
            if let footer = chapter.description {
                Text(footer)
            }
        }
    }
    
    func outlineGroup(_ chapter: Chapter) -> some View {
        OutlineGroup(chapter.topics, children: \.children) { item in
            NavigationLink {
                ScrollViewReader { scroll in
                    ScrollView {
                        Color.clear
                            .frame(height: 0)
                            .id("top")
                        
                        ShowcaseTopic(item)
                            .navigationTitle(item.title)
                            .toolbar {
                                ToolbarItem {
                                    ShowcaseIndexMenu(item)
                                }
                            }
                    }
                    .scrollViewProxy(scroll)
                }
                
            } label: {
                Label {
                    Text(item.title).bold()
                } icon: {
                    if let icon = item.icon {
                        icon
                    } else {
                        chapter.icon ?? document.icon
                    }
                }
            }
        }
    }
}

struct ShowcaseList_Previews: PreviewProvider {
    static var elements: [Topic] = [
        .mockButton,
        .mockCard,
        .mockAccordion
    ]
    
    static var previews: some View {
        ShowcaseDocument(
            .init(
                "Test",
                Chapter(
                    "Chapter",
                    elements
                )))
        
    }
}

func write(_ content: String) throws {
    guard let data = content.data(using: .utf8) else { throw NSError() }
    try FileHandle.standardOutput.write(contentsOf: data)
}
