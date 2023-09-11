import Foundation

public struct ShowcaseSection: Identifiable {
    public var id: String { "section-\(title)" }
    public var title: String
    public var data: [ShowcaseItem]
    
    public init(_ title: String, data: [ShowcaseItem]) {
        self.title = title
        self.data = data.naturalSort()
    }
}
