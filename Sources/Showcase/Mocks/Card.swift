import SwiftUI

// MARK: - Card Group

extension ShowcaseItem {
    static let card = Self(
        name: "Card",
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

extension ShowcaseItem {
    static let navigationalCard = Self(
        name: "Navigational Card",
        description: {
"""
The purpose of navigational cards is to provide users access to more detailed information or navigational elements (other pages).

By clicking anywhere on the card, users can perform the desired action. While navigational cards can include interactive elements for additional calls to action, it is not recommended.
"""
        },
        links: {
            Link("Code", .init(string: "NavigationalCard"))
            Link("Design", .init(string: "https://google.com"))
        },
        codeExamples: {
            
            CodeExample("elevated") { """
NavigationalCard {
    // action
} label: {
    Text("I'm content")
}
.cardStyle(.elevated())
"""
            }
            
            CodeExample("outlined") { """
NavigationalCard {
    // action
} label: {
    Text("I'm content")
}
.cardStyle(.outlined())
"""
            }
            
        },
        previews: {
            Text("Placeholder").opacity(0.3)
        }
    )
}

// MARK: - Selectable Card

extension ShowcaseItem {
    static let selectableCard = Self(
        name: "Selectable Card",
        description: {
"""
Selectable cards serve for selecting an item that is part of a group of options with rich content displayed inside each option, which would be too complex for buttons to contain.
"""
        },
        links: {
            Link("Code", .init(string: "SelectableCard"))
            Link("Design", .init(string: "https://google.com"))
        },
        codeExamples: { """
SelectableCard(isOn: $isOn) {
    Text("I'm content")
}
.cardStyle(.elevated())
"""
        },
        previews: {
            Text("Placeholder").opacity(0.3)
        }
    )
}

// MARK: - Static Card

extension ShowcaseItem {
    static let staticCard = Self(
        name: "Static Card",
        description: {
"""
A static card can have interactive elements such as a call-to-action button, but it is not intended for navigation or selection.

The card surface does not have interactive states, meaning it cannot be hovered or selected. However, it does contain other interactive components. An example of a static card is a recipe card.
"""
        },
        links: {
            Link("Code", .init(string: "StaticCard"))
            Link("Design", .init(string: "https://google.com"))
        },
        codeExamples: {
"""
StaticCard {
    Text("I'm content")
}
// .cardStyle(.outlined()) optional
"""
        },
        previews: {
            Text("Placeholder").opacity(0.3)
        }
    )
}

struct card_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Showcase(.card)
        }
    }
}
