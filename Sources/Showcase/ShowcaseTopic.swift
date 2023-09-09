import SwiftUI

public struct ShowcaseTopic: Identifiable {
    
    public var id: String { name }
    
    public var name: String
    
    public var description: String
    
    public var links: [Link]
    
    public var codeExamples: [CodeExample]
    
    public var previewRatio: CGSize = .init(width: 3, height: 2)
    
    public var previews: AnyView?
    
    public var children: [ShowcaseTopic] = []
    
    public init<V: View>(
        name: String,
        description: () -> String,
        @LinkBuilder links: () -> [Link] = { [] },
        @CodeExampleBuilder codeExamples: () -> [CodeExample] = { [] },
        children: [ShowcaseTopic] = [],
        previewRatio: CGSize = .init(width: 3, height: 2),
        @ViewBuilder previews: () -> V
    ) {
        self.children = children
        self.codeExamples = codeExamples()
        self.description = description()
        self.links = links()
        self.name = name
        self.previews = AnyView(previews())
        self.previewRatio = previewRatio
    }
    
    public init(
        name: String,
        description: () -> String,
        @LinkBuilder links: () -> [Link] = { [] },
        @CodeExampleBuilder codeExamples: () -> [CodeExample] = { [] },
        children: [ShowcaseTopic] = []
    ) {
        self.name = name
        self.children = children
        self.codeExamples = codeExamples()
        self.description = description()
        self.links = links()
        self.previews = nil
        self.previewRatio = .zero
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
    public static func buildBlock() -> [ShowcaseTopic.Link] { [] }
    public static func buildBlock(_ components: ShowcaseTopic.Link...) -> [ShowcaseTopic.Link] { components }
    public static func buildBlock(_ components: ShowcaseTopic.Link?...) -> [ShowcaseTopic.Link] { components.compactMap { $0 } }
}

@resultBuilder
public struct CodeExampleBuilder {
    public static func buildBlock() -> [ShowcaseTopic.CodeExample] { [] }
    public static func buildBlock(_ components: ShowcaseTopic.CodeExample...) -> [ShowcaseTopic.CodeExample] { components }
    public static func buildBlock(_ components: String...) -> [ShowcaseTopic.CodeExample] { components.map { .init(stringLiteral: $0) } }
}
