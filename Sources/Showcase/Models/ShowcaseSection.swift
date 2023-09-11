import Foundation

public struct ShowcaseSection: Identifiable {
    public var id: String { "section-\(title)" }
    public var title: String
    public var data: [ShowcaseElement]
    
    public init(_ title: String, elements: [ShowcaseElement]) {
        self.title = title
        self.data = elements.naturalSort()
    }
}
