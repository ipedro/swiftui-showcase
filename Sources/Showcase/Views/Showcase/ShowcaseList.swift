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
public struct ShowcaseList<Icon: View>: View {
    /// The data representing showcase chapters.
    let data: [ShowcaseChapter]
    
    /// The icon to be displayed next to each showcase item in the list.
    let icon: Icon
    
    /// Initializes a showcase list with the specified data and optional icon.
    /// - Parameters:
    ///   - data: The data representing showcase chapters.
    ///   - icon: A closure that returns the icon view for each showcase item (optional).
    public init(
        _ data: [ShowcaseChapter],
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.data = data
        self.icon = icon()
    }
    
    /// Initializes a showcase list with the specified data and optional icon.
    /// - Parameters:
    ///   - data: The data representing showcase chapters.
    ///   - icon: A closure that returns the icon view for each showcase item (optional).
    public init(
        _ data: ShowcaseChapter...,
        @ViewBuilder icon: () -> Icon = { EmptyView() }
    ) {
        self.data = data
        self.icon = icon()
    }
    
    public var body: some View {
        List {
            ForEach(data) { chapter in
                Section(chapter.title) {
                    OutlineGroup(chapter.data, children: \.children) { item in
                        NavigationLink {
                            Showcase(item)
                        } label: {
                            Label {
                                Text(item.content.title)
                            } icon: {
                                icon
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ShowcaseList_Previews: PreviewProvider {
    static var elements: [ShowcaseTopic] = [
        .mockAccordion,
        .mockCard
    ]
    
    static var previews: some View {
        NavigationView {
            ShowcaseList(
                ShowcaseChapter("List", elements)
            )
        }
    }
}
