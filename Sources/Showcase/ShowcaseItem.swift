import SwiftUI

public struct ShowcaseItem: Identifiable {
    
    public var id: String { section.name }
    
    public var section: Section
    
    public var children: [ShowcaseItem] = []
    
    public init<V: View>(
        name: String,
        description: () -> String,
        @LinkBuilder links: () -> [Link] = { [] },
        @CodeExampleBuilder codeExamples: () -> [CodeExample] = { [] },
        children: [ShowcaseItem] = [],
        previewRatio: CGSize = .init(width: 3, height: 2),
        @ViewBuilder previews: () -> V
    ) {
        self.children = children
        self.section = .init(
            name: name,
            description: description(),
            links: links(),
            codeExamples: codeExamples(),
            previews: .init(
                aspectRatio: previewRatio,
                previews: .init(previews()))
        )
    }
    
    public init(
        name: String,
        description: () -> String,
        @LinkBuilder links: () -> [Link] = { [] },
        @CodeExampleBuilder codeExamples: () -> [CodeExample] = { [] },
        children: [ShowcaseItem] = []
    ) {
        self.children = children
        self.section = .init(
            name: name,
            description: description(),
            links: links(),
            codeExamples: codeExamples())
    }
    
    public struct Previews {
        public var aspectRatio: CGFloat
        public var previews: AnyView
        
        init(aspectRatio: CGSize, previews: AnyView) {
            self.aspectRatio = aspectRatio.width / aspectRatio.height
            self.previews = previews
        }
    }
    
    public struct Section: Identifiable {
        public var id: String { name }
        public var name: String
        public var description: String
        public var links: [Link]
        public var codeExamples: [CodeExample]
        public var previews: Previews?
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
    
    public struct Link: Identifiable {
        public var name: LinkName
        public var url: URL
        public var id: String { url.absoluteString }
        
        public init?(_ name: LinkName, _ url: URL?) {
            guard let url = url else { return nil }
            self.name = name
            self.url = url
        }
    }
    
    public struct CodeExample: Identifiable, ExpressibleByStringLiteral {
        public var text: String
        public var title: String
        public var id: String { text }
        
        public init(_ title: String, text: () -> String) {
            self.title = title
            self.text = text()
        }

        public init(stringLiteral value: String) {
            text = value
            title = "Sample Code"
        }
    }
}

@resultBuilder
public struct LinkBuilder {
    public static func buildBlock() -> [ShowcaseItem.Link] { [] }
    public static func buildBlock(_ components: ShowcaseItem.Link...) -> [ShowcaseItem.Link] { components }
    public static func buildBlock(_ components: ShowcaseItem.Link?...) -> [ShowcaseItem.Link] { components.compactMap { $0 } }
}

@resultBuilder
public struct CodeExampleBuilder {
    public static func buildBlock() -> [ShowcaseItem.CodeExample] { [] }
    public static func buildBlock(_ components: ShowcaseItem.CodeExample...) -> [ShowcaseItem.CodeExample] { components }
    public static func buildBlock(_ components: String...) -> [ShowcaseItem.CodeExample] { components.map { .init(stringLiteral: $0) } }
}
