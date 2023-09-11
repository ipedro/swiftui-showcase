import SwiftUI

extension ShowcaseItem {
    static let accordion = Self(
        title: "Accordion",
        description: { """
    Accordions enable users to expand and collapse multiple sections of content.
    
    An accordion is vertically stacked set of interactive headings that each contain a headline and description representing a section of content.
    
    They are useful for breaking down long and complex content into smaller digestible chunks and to reduce information overload.
    
    Commonly used for content that is useful but not essential such as frequently asked questions (FAQs), or for displaying multiple blocks of related content.
    """
        },
        links: {
            ExternalLink("Code", .init(string: "https://google.com"))
            ExternalLink("Design", .init(string: "https://zeroheight.com/700c95a05/p/0309e1-accordion/b/45490a"))
        },
        examples: {
    """
    Accordion(data, selection: $selectedRow) { item in
        Text(item.title).bold()
    } rowContent: { item in
        Text(item.content)
    }
    """
    
    """
    Accorjhjhjdion(data, selection: $selectedRow) { item in
        Text(item.title).bold()
    } rowContent: { item in
        Text(item.content)
    }
    """
        },
        previews: .init {
            MockPreviews()
        }
    )
}

struct ShowcaseTopicAccordion_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Showcase(.accordion)
        }
    }
}
