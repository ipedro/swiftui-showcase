import SwiftUI

public struct ShowcaseItem: Identifiable {
    public var id: String { content.id }
    var content: Content
    var children: [ShowcaseItem]?
    
    public init(
        title: String,
        description: () -> String,
        @ExternalLinkBuilder links: () -> [ExternalLink] = { [] },
        @CodeBlockBuilder snippets: () -> [CodeBlock] = { [] },
        children: [ShowcaseItem]? = nil,
        previews: Previews? = nil
    ) {
        self.children = children
        self.content = .init(
            description: description(),
            links: links(),
            previews: previews,
            snippets: snippets(),
            title: title)
    }
    
    public struct Content: Identifiable {
        public var description: String
        public var id: String { title }
        public var links: [ExternalLink]
        public var previews: Previews?
        public var snippets: [CodeBlock]
        public var title: String
    }
    
    public struct Previews {
        public var minWidth: CGFloat?
        public var idealWidth: CGFloat?
        public var maxWidth: CGFloat?
        public var minHeight: CGFloat?
        public var idealHeight: CGFloat?
        public var maxHeight: CGFloat?
        public var alignment: Alignment
        public var content: AnyView
        
        public init<V: View>(
            minWidth: CGFloat? = nil,
            idealWidth: CGFloat? = nil,
            maxWidth: CGFloat? = nil,
            minHeight: CGFloat? = nil,
            idealHeight: CGFloat? = 250,
            maxHeight: CGFloat? = nil,
            alignment: Alignment = .center,
            @ViewBuilder content: () -> V
        ) {
            self.minWidth = minWidth
            self.idealWidth = idealWidth
            self.maxWidth = maxWidth
            self.minHeight = minHeight
            self.idealHeight = idealHeight
            self.maxHeight = maxHeight
            self.alignment = alignment
            self.content = .init(content())
        }
    }

    public struct LinkName: CustomStringConvertible, ExpressibleByStringLiteral {
        public var description: String
        public init(_ description: String) {
            self.description = description
        }
        public init(stringLiteral value: String) {
            self.description = value
        }
    }
    
    public struct ExternalLink: Identifiable {
        public var title: LinkName
        public var url: URL
        public var id: String { url.absoluteString }
        
        public init?(_ title: LinkName, _ url: URL?) {
            guard let url = url else { return nil }
            self.title = title
            self.url = url
        }
    }
    
    public struct CodeBlock: Identifiable, RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String
        public var title: String?
        public var id: String { rawValue }
        
        
        public init?(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(_ title: String? = nil, text: () -> String) {
            self.title = title
            self.rawValue = text()
        }

        public init(stringLiteral value: String) {
            rawValue = value
        }
    }
    
    @resultBuilder
    public struct ExternalLinkBuilder {
        public static func buildBlock() -> [ExternalLink] { [] }
        public static func buildBlock(_ components: ExternalLink...) -> [ExternalLink] { components }
        public static func buildBlock(_ components: ExternalLink?...) -> [ExternalLink] { components.compactMap { $0 } }
    }

    @resultBuilder
    public struct CodeBlockBuilder {
        public static func buildBlock() -> [CodeBlock] { [] }
        public static func buildBlock(_ components: CodeBlock...) -> [CodeBlock] { components }
        public static func buildBlock(_ components: String...) -> [CodeBlock] { components.map { .init(stringLiteral: $0) } }
    }

}
