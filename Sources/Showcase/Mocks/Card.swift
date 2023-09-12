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

// MARK: - Card Group

extension ShowcaseTopic {
    public static let mockCard = Self(
        title: "Card",
        description: {
            "Cards are surfaces that display content and actions on a single topic."
        },
        children: [
            .staticCard,
            .navigationalCard,
            .selectableCard
        ]
    )
}

// MARK: - Navigational Card

extension ShowcaseTopic {
    static let navigationalCard = Self(
        title: "Navigational Card",
        description: {
"""
The purpose of navigational cards is to provide users access to more detailed information or navigational elements (other pages).

By clicking anywhere on the card, users can perform the desired action. While navigational cards can include interactive elements for additional calls to action, it is not recommended.
"""
        },
        links: {
            ExternalLink("Code", .init(string: "NavigationalCard"))
            ExternalLink("Design", .init(string: "https://google.com"))
        },
        examples: {
            
            CodeBlock("elevated") { """
NavigationalCard {
    // action
} label: {
    Text("I'm content")
}
"""
            }
            
            CodeBlock("outlined") { """
NavigationalCard {
    // action
} label: {
    Text("I'm content")
}
"""
            }
            
        },
        previews: .init {
            MockPreviews()
        }
    )
}

// MARK: - Selectable Card

extension ShowcaseTopic {
    static let selectableCard = Self(
        title: "Selectable Card",
        description: {
"""
Selectable cards serve for selecting an item that is part of a group of options with rich content displayed inside each option, which would be too complex for buttons to contain.
"""
        },
        links: {
            ExternalLink("Code", .init(string: "SelectableCard"))
            ExternalLink("Design", .init(string: "https://google.com"))
        },
        examples: { """
SelectableCard(isOn: $isOn) {
    Text("I'm content")
}
"""
        },
        previews: .init {
            MockPreviews()
        }
    )
}

// MARK: - Static Card

extension ShowcaseTopic {
    static let staticCard = Self(
        title: "Static Card",
        description: {
"""
A static card can have interactive elements such as a call-to-action button, but it is not intended for navigation or selection.

The card surface does not have interactive states, meaning it cannot be hovered or selected. However, it does contain other interactive components. An example of a static card is a recipe card.
"""
        },
        links: {
            ExternalLink("Code", .init(string: "StaticCard"))
            ExternalLink("Design", .init(string: "https://google.com"))
        },
        examples: {
"""
StaticCard {
    Text("I'm content")
}
"""
        },
        previews: .init {
            MockPreviews()
        }
    )
}

struct card_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Showcase(.mockCard)
        }
    }
}
