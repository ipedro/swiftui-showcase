import SwiftUI

/// Represents a showcase element used for displaying rich documentation.
///
/// The documentation can include code examples, descriptions, previews and links.
public struct ShowcaseElement: Identifiable {
    /// The unique identifier for this showcase element.
    public var id: String { content.id }
    
    /// The content of the showcase element.
    public let content: Content
    
    /// Optional child showcase elements.
    public let children: [ShowcaseElement]?
    
    /// Initializes a showcase element with the specified parameters.
    /// - Parameters:
    ///   - title: The title of the showcase element.
    ///   - description: A closure returning the description of the showcase element (default is an empty string).
    ///   - links: A closure returning external links associated with the showcase element (default is an empty array).
    ///   - examples: A closure returning code examples (default is an empty array).
    ///   - children: Optional child showcase elements (default is nil).
    ///   - previews: Previews configuration (default is nil).
    public init(
        title: String,
        description: () -> String = { "" },
        @ExternalLinkBuilder links: () -> [ExternalLink] = { [] },
        @CodeBlockBuilder examples: () -> [CodeBlock] = { [] },
        children: [ShowcaseElement]? = nil,
        previews: Previews? = nil
    ) {
        self.children = children
        self.content = .init(
            codeBlocks: examples(),
            description: description(),
            links: links(),
            previews: previews,
            title: title)
    }
    
    /// Represents the content of a showcase element.
    public struct Content: Identifiable {
        /// The unique identifier for the content.
        public var id: String { title }
        
        /// Code blocks associated with the content.
        public let codeBlocks: [CodeBlock]
        
        /// Description of the content.
        public let description: String
        
        /// External links associated with the content.
        public let links: [ExternalLink]
        
        /// Previews configuration for the content.
        public let previews: Previews?
        
        /// Title of the content.
        public let title: String
    }
    
    /// Represents the previews configuration for a showcase element's content.
    public struct Previews {
        /// Minimum width of the preview.
        public let minWidth: CGFloat?
        
        /// Ideal width of the preview.
        public let idealWidth: CGFloat?
        
        /// Maximum width of the preview.
        public let maxWidth: CGFloat?
        
        /// Minimum height of the preview.
        public let minHeight: CGFloat?
        
        /// Ideal height of the preview.
        public let idealHeight: CGFloat?
        
        /// Maximum height of the preview.
        public let maxHeight: CGFloat?
        
        /// Alignment of the preview content.
        public let alignment: Alignment
        
        /// Title of the preview.
        public let title: String?
        
        /// The content to be displayed in the preview.
        public let content: AnyView
        
        /// Initializes the previews configuration with the specified parameters.
        /// - Parameters:
        ///   - minWidth: Minimum width of the preview (default is nil).
        ///   - idealWidth: Ideal width of the preview (default is nil).
        ///   - maxWidth: Maximum width of the preview (default is nil).
        ///   - minHeight: Minimum height of the preview (default is nil).
        ///   - idealHeight: Ideal height of the preview (default is 250).
        ///   - maxHeight: Maximum height of the preview (default is nil).
        ///   - alignment: Alignment of the content within the preview (default is .center).
        ///   - title: The title of the preview (default is nil).
        ///   - content: A closure returning the content of the preview.
        public init<V: View>(
            minWidth: CGFloat? = nil,
            idealWidth: CGFloat? = nil,
            maxWidth: CGFloat? = nil,
            minHeight: CGFloat? = nil,
            idealHeight: CGFloat? = 200,
            maxHeight: CGFloat? = nil,
            alignment: Alignment = .center,
            title: String? = nil,
            @ViewBuilder content: () -> V
        ) {
            self.minWidth = minWidth
            self.idealWidth = idealWidth
            self.maxWidth = maxWidth
            self.minHeight = minHeight
            self.idealHeight = idealHeight
            self.maxHeight = maxHeight
            self.alignment = alignment
            self.title = title
            self.content = .init(content())
        }
    }

    /// Represents the name of an external link.
    public struct LinkName: CustomStringConvertible, ExpressibleByStringLiteral {
        /// The description of the link name.
        public let description: String
        
        /// Initializes a link name with the specified description.
        /// - Parameter description: The description of the link name.
        public init(_ description: String) {
            self.description = description
        }
        
        /// Initializes a link name using a string literal.
        /// - Parameter value: The string literal representing the link name description.
        public init(stringLiteral value: String) {
            self.description = value
        }
    }
    
    /// Represents an external link associated with a showcase element.
    public struct ExternalLink: Identifiable {
        /// The unique identifier for the external link (based on the URL).
        public var id: String { url.absoluteString }
        
        /// The title of the external link.
        public let title: LinkName
        
        /// The URL of the external link.
        public let url: URL
        
        /// Initializes an external link with the specified title and URL.
        /// - Parameters:
        ///   - title: The title of the external link.
        ///   - url: The URL of the external link.
        public init?(_ title: LinkName, _ url: URL?) {
            guard let url = url else { return nil }
            self.title = title
            self.url = url
        }
    }
    
    /// Represents a code block associated with a showcase element.
    public struct CodeBlock: Identifiable, RawRepresentable, ExpressibleByStringLiteral {
        /// The unique identifier for the code block.
        public var id: String { rawValue }
        
        /// The raw string value of the code block.
        public let rawValue: String
        
        /// Optional title for the code block.
        public let title: String?
        
        /// Initializes a code block from raw text.
        public init?(rawValue: String) {
            self.title = nil
            self.rawValue = rawValue
        }
        
        /// Initializes a code block with a title and raw text.
        /// - Parameters:
        ///   - title: Optional title for the code block.
        ///   - text: A closure returning the raw text content of the code block.
        public init(_ title: String? = nil, text: () -> String) {
            self.title = title
            self.rawValue = text()
        }

        /// Initializes a code block using a string literal.
        /// - Parameter value: The string literal representing the code block's raw content.
        public init(stringLiteral value: String) {
            title = nil
            rawValue = value
        }
    }
    
    /// A result builder for creating external links.
    @resultBuilder public struct ExternalLinkBuilder {
        /// Builds an array of external links from individual components.
        public static func buildBlock() -> [ExternalLink] { [] }
        
        /// Builds an array of external links from variadic components.
        public static func buildBlock(_ components: ExternalLink...) -> [ExternalLink] { components }
        
        /// Builds an array of external links from optional components, filtering out nil values.
        public static func buildBlock(_ components: ExternalLink?...) -> [ExternalLink] { components.compactMap { $0 } }
    }

    /// A result builder for creating code blocks.
    @resultBuilder public struct CodeBlockBuilder {
        /// Builds an array of code blocks from individual components.
        public static func buildBlock() -> [CodeBlock] { [] }
        
        /// Builds an array of code blocks from variadic components.
        public static func buildBlock(_ components: CodeBlock...) -> [CodeBlock] { components }
        
        /// Builds an array of code blocks from variadic string components.
        public static func buildBlock(_ components: String...) -> [CodeBlock] { components.map { .init(stringLiteral: $0) } }
    }
}
