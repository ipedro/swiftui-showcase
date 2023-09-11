import Foundation

public struct ShowcaseLibrary: Identifiable {
    public var id: String { "library-\(title)" }
    public var title: String
    public var sections: [ShowcaseSection]
    
    public init(_ title: String, sections: [ShowcaseSection]) {
        self.title = title
        self.sections = sections.naturalSort()
    }
}
