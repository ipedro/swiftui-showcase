import SwiftUI

public struct ShowcaseItem: Identifiable {
    public var id: String { content.id }
    public let content: Content
    public let children: [ShowcaseItem]?
    
    public init(
        title: String,
        description: () -> String = { "" },
        @ExternalLinkBuilder links: () -> [ExternalLink] = { [] },
        @CodeBlockBuilder examples: () -> [CodeBlock] = { [] },
        children: [ShowcaseItem]? = nil,
        previews: Previews? = nil
    ) {
        self.children = children?.naturalSort()
        self.content = .init(
            codeBlocks: examples(),
            description: description(),
            links: links(),
            previews: previews,
            title: title)
    }
    
    public struct Content: Identifiable {
        public var id: String { title }
        public let codeBlocks: [CodeBlock]
        public let description: String
        public let links: [ExternalLink]
        public let previews: Previews?
        public let title: String
    }
    
    public struct Previews {
        public let minWidth: CGFloat?
        public let idealWidth: CGFloat?
        public let maxWidth: CGFloat?
        public let minHeight: CGFloat?
        public let idealHeight: CGFloat?
        public let maxHeight: CGFloat?
        public let alignment: Alignment
        public let content: AnyView
        
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
        public let description: String
        
        public init(_ description: String) {
            self.description = description
        }
        public init(stringLiteral value: String) {
            self.description = value
        }
    }
    
    public struct ExternalLink: Identifiable {
        public var id: String { url.absoluteString }
        public let title: LinkName
        public let url: URL
        
        public init?(_ title: LinkName, _ url: URL?) {
            guard let url = url else { return nil }
            self.title = title
            self.url = url
        }
    }
    
    public struct CodeBlock: Identifiable, RawRepresentable, ExpressibleByStringLiteral {
        public var id: String { rawValue }
        public let rawValue: String
        public let title: String?
        
        public init?(rawValue: String) {
            self.title = nil
            self.rawValue = rawValue
        }
        
        public init(_ title: String? = nil, text: () -> String) {
            self.title = title
            self.rawValue = text()
        }

        public init(stringLiteral value: String) {
            title = nil
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
