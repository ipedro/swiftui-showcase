import Foundation

/// Represents a library of showcase sections containing code examples, descriptions, and links.
public struct ShowcaseLibrary: Identifiable {
    /// The unique identifier for the library.
    public var id: String { "library-\(title)" }
    
    /// The title of the library.
    public let title: String
    
    /// The sections within the library.
    public let sections: [ShowcaseSection]
    
    /// Initializes a showcase library with the specified title and sections.
    /// - Parameters:
    ///   - title: The title of the library.
    ///   - sections: The sections within the library.
    public init(_ title: String, _ sections: [ShowcaseSection]) {
        self.title = title
        self.sections = sections.naturalSort()
    }
    
    /// Initializes a showcase library with the specified title and sections.
    /// - Parameters:
    ///   - title: The title of the library.
    ///   - sections: The sections within the library.
    public init(_ title: String, _ sections: ShowcaseSection...) {
        self.title = title
        self.sections = sections.naturalSort()
    }
}
