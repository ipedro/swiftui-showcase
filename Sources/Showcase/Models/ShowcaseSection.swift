import Foundation

/// Represents a section within a showcase library, containing showcase elements.
public struct ShowcaseSection: Identifiable {
    /// The unique identifier for the section.
    public var id: String { "section-\(title)" }
    
    /// The title of the section.
    public let title: String
    
    /// The showcase elements within the section.
    public let data: [ShowcaseElement]
    
    /// Initializes a showcase section with the specified title and showcase elements.
    /// - Parameters:
    ///   - title: The title of the section.
    ///   - elements: The showcase elements within the section.
    public init(_ title: String, elements: [ShowcaseElement]) {
        self.title = title
        self.data = elements.naturalSort()
    }
}
