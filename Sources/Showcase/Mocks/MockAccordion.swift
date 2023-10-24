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

extension Topic {
    public static let mockAccordion = Self(
        "Accordion",
        description: { """
    Accordions enable users to expand and collapse multiple sections of content.
    
    An accordion is vertically stacked set of interactive headings that each contain a headline and description representing a section of content.
    
    They are useful for breaking down long and complex content into smaller digestible chunks and to reduce information overload.
    
    Commonly used for content that is useful but not essential such as frequently asked questions (FAQs), or for displaying multiple blocks of related content.
    """
        },
        links: {
            Link("Code", .init(string: "https://google.com"))
            Link("Design", .init(string: "https://zeroheight.com/700c95a05/p/0309e1-accordion/b/45490a"))
        },
        code: {
    """
    Accordion(data, selection: $selectedRow) { item in
        Text(item.title).bold()
    } rowContent: { item in
        Text(item.content)
    }
    """
    
    """
    Accordion(data, selection: $selectedRow) { item in
        Text(item.title).bold()
    } rowContent: { item in
        Text(item.content)
    }
    """
        },
        children: [.mockCard],
        previews: {
            MockPreviews()
        }
    )
}

struct TopicAccordion_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowcaseDocument(
                .init(
                    "Accordion",
                    Chapter(
                        "Chapter",
                        .mockAccordion
                    )
                )
            )
        }
    }
}
