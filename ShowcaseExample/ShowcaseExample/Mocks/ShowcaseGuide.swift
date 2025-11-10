//
//  ShowcaseGuide.swift
//  ShowcaseExample
//
//  Created by Pedro Almeida on 09.11.24.
//

import SwiftUI
import Showcase

// MARK: - Main Document

extension Document {
    static let showcaseGuide = Document("Showcase API") {
        Chapter.gettingStarted
        Chapter.coreConceptsChapter
        Chapter.contentTypes
        Chapter.advancedFeatures
        Chapter.designSystem
    }
}

// MARK: - Chapter 1: Getting Started

extension Chapter {
    static let gettingStarted = Chapter("Getting Started") {
        Description("Learn the basics of Showcase and create your first documentation")
        
        Topic.whatIsShowcase
        Topic.installation
        Topic.quickStart
    }
}

extension Topic {
    static let whatIsShowcase = Topic("What is Showcase?") {
        Description {
            """
            Showcase is a SwiftUI framework designed for creating beautiful, interactive documentation \
            for your components, APIs, and design systems.
            
            Perfect for:
            - Component libraries and design systems
            - API documentation and examples
            - Interactive tutorials and guides
            - Technical documentation with live demos
            """
        }
        
        VStack(alignment: .leading, spacing: 16) {
            Label("Declarative DSL", systemImage: "curlybraces")
                .font(.headline)
            Text("Build documentation using intuitive Swift syntax")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Label("Live Examples", systemImage: "play.rectangle")
                .font(.headline)
            Text("Embed interactive SwiftUI views")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Label("Organized Content", systemImage: "folder.fill")
                .font(.headline)
            Text("Structure docs with chapters and topics")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)

        ExternalLink("GitHub Repository", URL(string: "https://github.com/ipedro/swiftui-showcase")!)
    }
    
    static let installation = Topic("Installation") {
        Description("Add Showcase to your project using Swift Package Manager")
        
        CodeBlock("Package.swift") {
            """
            dependencies: [
                .package(
                    url: "https://github.com/ipedro/swiftui-showcase.git",
                    from: "1.0.0"
                )
            ]
            """
        }
        
        CodeBlock("Xcode") {
            """
            1. File → Add Package Dependencies...
            2. Enter: https://github.com/ipedro/swiftui-showcase.git
            3. Select version and add to your target
            """
        }
        
        VStack(spacing: 12) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Swift Package Manager")
                .font(.headline)

            Text("Zero configuration required")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    static let quickStart = Topic("Quick Start") {
        Description("Create your first Showcase document in minutes")
        
        // CODE FIRST - demonstrating ordered content!
        CodeBlock("Basic Example") {
            """
            import SwiftUI
            import Showcase
            
            struct ContentView: View {
                var body: some View {
                    ShowcaseNavigationStack(
                        Document("My Components") {
                            Chapter("UI Elements") {
                                Topic("Button") {
                                    Description("A tappable control")
                                    
                                    CodeBlock {
                                        "Button(\\"Tap Me\\") { }"
                                    }
                                    
                                    Example {
                                        Button("Tap Me") { }
                                            .buttonStyle(.borderedProminent)
                                    }
                                }
                            }
                        }
                    )
                }
            }
            """
        }
        
        Description {
            """
            This creates a complete documentation structure with:
            - A document as the top-level container
            - A chapter to group related topics
            - A topic with description, code, and live example
            """
        }
        
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "doc.fill")
                Text("Document: My Components")
                    .font(.headline)
            }

            HStack {
                Image(systemName: "folder.fill")
                    .padding(.leading, 20)
                Text("Chapter: UI Elements")
                    .font(.subheadline)
            }

            HStack {
                Image(systemName: "doc.text.fill")
                    .padding(.leading, 40)
                Text("Topic: Button")
                    .font(.caption)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)

        ExternalLink("Full Documentation", URL(string: "https://github.com/ipedro/swiftui-showcase#readme")!)
    }
}

// MARK: - Chapter 2: Core Concepts

extension Chapter {
    static let coreConceptsChapter = Chapter("Core Concepts") {
        Description("Understand the fundamental building blocks of Showcase")
        
        Topic.documents
        Topic.chapters
        Topic.topics
        Topic.contentHierarchy
    }
}

extension Topic {
    static let documents = Topic("Documents") {
        Description {
            """
            A Document is the top-level container for your documentation. It typically represents \
            a complete library, framework, or design system.
            
            Documents can contain multiple chapters and provide an overall description of your content.
            """
        }
        
        CodeBlock {
            """
            Document("My Design System") {
                Description("Complete UI component library")
                
                Chapter("Foundations") { ... }
                Chapter("Components") { ... }
                Chapter("Patterns") { ... }
            }
            """
        }
        
        VStack(spacing: 16) {
            Image(systemName: "book.fill")
                .font(.system(size: 48))
                .foregroundStyle(.purple)

            Text("Top-Level Container")
                .font(.headline)

            Text("Organizes all your documentation")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    static let chapters = Topic("Chapters") {
        Description {
            """
            Chapters group related topics together. Use them to organize your documentation \
            into logical sections.
            
            Each chapter can have its own description and icon, making navigation intuitive.
            """
        }
        
        CodeBlock {
            """
            Chapter("Getting Started") {
                Description("Learn the basics")
                
                Topic("Installation") { ... }
                Topic("Quick Start") { ... }
                Topic("Configuration") { ... }
            }
            """
        }
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundStyle(.blue)
                Text("Chapter: Getting Started")
                    .font(.headline)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "doc.text")
                    Text("Topic: Installation")
                        .font(.subheadline)
                }
                HStack {
                    Image(systemName: "doc.text")
                    Text("Topic: Quick Start")
                        .font(.subheadline)
                }
                HStack {
                    Image(systemName: "doc.text")
                    Text("Topic: Configuration")
                        .font(.subheadline)
                }
            }
            .padding(.leading, 20)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    static let topics = Topic("Topics") {
        Description {
            """
            Topics are the individual pages of your documentation. Each topic can contain:
            - Descriptions
            - Code examples
            - Live previews
            - External links
            - Embedded content
            - Nested sub-topics
            """
        }
        
        CodeBlock {
            """
            Topic("Button Component") {
                Description("Interactive tappable control")
                
                CodeBlock("Usage") {
                    "Button(\\"Submit\\") { submit() }"
                }
                
                Example {
                    Button("Submit") { }
                }
                
                ExternalLink("HIG", URL(string: "...")!)
            }
            """
        }
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Topic: Button Component")
                .font(.title2)
                .bold()

            Text("Interactive tappable control")
                .foregroundStyle(.secondary)

            Divider()

            Text("Code, examples, links, and more...")
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    static let contentHierarchy = Topic("Content Hierarchy") {
        Description {
            """
            Showcase supports nested topics, allowing you to create deep hierarchies of content. \
            This is perfect for complex documentation with multiple levels of detail.
            """
        }
        
        CodeBlock {
            """
            Topic("Components") {
                Topic("Buttons") {
                    Topic("Primary Button") { ... }
                    Topic("Secondary Button") { ... }
                }
                
                Topic("Forms") {
                    Topic("Text Fields") { ... }
                    Topic("Pickers") { ... }
                }
            }
            """
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("📁 Components")
                .font(.headline)

            Text("  📁 Buttons")
                .font(.subheadline)
                .padding(.leading, 12)

            Text("    📄 Primary Button")
                .font(.caption)
                .padding(.leading, 24)

            Text("    📄 Secondary Button")
                .font(.caption)
                .padding(.leading, 24)

            Text("  📁 Forms")
                .font(.subheadline)
                .padding(.leading, 12)

            Text("    📄 Text Fields")
                .font(.caption)
                .padding(.leading, 24)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Chapter 3: Content Types

extension Chapter {
    static let contentTypes = Chapter("Content Types") {
        Description("Explore the different types of content you can include in your topics")
        
        Topic.codeBlocks
        Topic.examples
        Topic.externalLinks
        Topic.embeds
        Topic.notes
    }
}

extension Topic {
    static let codeBlocks = Topic("Code Blocks") {
        Description {
            """
            Display syntax-highlighted code examples in your documentation. \
            Code blocks support multiple languages and are styled for readability.
            """
        }
        
        CodeBlock("Swift") {
            """
            struct ContentView: View {
                var body: some View {
                    Text("Hello, World!")
                        .font(.title)
                }
            }
            """
        }
        
        CodeBlock("JSON") {
            """
            {
                "name": "Showcase",
                "version": "1.0.0",
                "platform": "iOS, macOS"
            }
            """
        }
        
        CodeBlock("Markdown") {
            """
            # Showcase Framework
            
            A **declarative** DSL for creating *beautiful* documentation.
            
            - Feature 1
            - Feature 2
            - Feature 3
            """
        }
        
        Description {
            """
            Code blocks automatically detect the language and apply appropriate syntax highlighting. \
            You can also specify a title for better context.
            """
        }
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "curlybraces")
                Text("Syntax Highlighting")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("✓ Swift")
                Text("✓ JSON")
                Text("✓ Markdown")
                Text("✓ And more...")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    static let examples = Topic("Examples") {
        Description {
            """
            Examples embed live SwiftUI views directly in your documentation. \
            This allows users to see and interact with your components in real-time.
            
            Perfect for demonstrating UI components, animations, and interactive behaviors.
            """
        }
        
        CodeBlock("Basic Example") {
            """
            Topic("Button") {
                Description("A tappable control")
                
                Button("Tap Me") {
                    print("Tapped!")
                }
                .buttonStyle(.borderedProminent)
            }
            """
        }
        
        Description {
            """
            **New in Showcase:** You can now include a `CodeBlock` directly inside an `Example` \
            to show both the live preview and its source code together. This creates an integrated \
            view with a collapsible code section.
            """
        }
        
        CodeBlock("Example with Inline Code") {
            """
            Example("Interactive Button") {
                Button("Tap Me") {
                    print("Tapped!")
                }
                .buttonStyle(.borderedProminent)
                
                CodeBlock("Source") {
                    \"\"\"
                    Button("Tap Me") {
                        print("Tapped!")
                    }
                    .buttonStyle(.borderedProminent)
                    \"\"\"
                }
            }
            """
        }
        
        Description {
            """
            You can also add `Description` blocks inside examples to provide additional context:
            """
        }
        
        CodeBlock("Example with Description") {
            """
            Example("Primary Button") {
                Description {
                    \"\"\"
                    This button style should be used for the main action on a screen.
                    It features high contrast and prominence.
                    \"\"\"
                }
                
                Button("Continue") {
                    print("Primary action")
                }
                .buttonStyle(.borderedProminent)
                
                CodeBlock("Source") {
                    \"\"\"
                    Button("Continue") {
                        print("Primary action")
                    }
                    .buttonStyle(.borderedProminent)
                    \"\"\"
                }
            }
            """
        }
        
        Example("Live Preview") {
            Description {
                """
                This example demonstrates a button with a description. The description \
                provides additional context about the component's intended use.
                """
            }
            
            VStack(spacing: 20) {
                Text("Live Example:")
                    .font(.headline)
                
                Button("Interactive Button") {
                    // Action
                }
                .buttonStyle(.borderedProminent)
                
                Text("This is a real, interactive SwiftUI view!")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
        }
        
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ForEach(["red", "blue", "green"], id: \.self) { color in
                    Circle()
                        .fill(color == "red" ? .red : color == "blue" ? .blue : .green)
                        .frame(width: 40, height: 40)
                }
            }

            Text("Multiple examples per topic")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
    
    static let externalLinks = Topic("External Links") {
        Description {
            """
            Link to external resources like documentation, design specs, or reference materials. \
            Links are styled consistently and open in Safari or embedded web views.
            """
        }
        
        CodeBlock {
            """
            Topic("Button") {
                ExternalLink(
                    "Human Interface Guidelines",
                    URL(string: "https://developer.apple.com/design/hig")!
                )
                
                ExternalLink(
                    "SwiftUI Button Docs",
                    URL(string: "https://developer.apple.com/documentation/swiftui/button")!
                )
            }
            """
        }
        
        ExternalLink("Apple HIG", URL(string: "https://developer.apple.com/design/human-interface-guidelines/")!)
        ExternalLink("SwiftUI Documentation", URL(string: "https://developer.apple.com/documentation/swiftui/")!)
        
        VStack(alignment: .leading, spacing: 12) {
            Label("External Resources", systemImage: "link.circle.fill")
                .font(.headline)

            Text("Links open in Safari or embedded views")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    static let embeds = Topic("Embeds") {
        Description {
            """
            Embed external web content directly in your documentation. \
            Perfect for design specs, live demos, interactive playgrounds, or reference materials.
            
            Embeds render web content inline using WKWebView.
            """
        }
        
        CodeBlock {
            """
            Topic("Design Spec") {
                Description("View the complete design specification")
                
                Embed(URL(string: "https://figma.com/file/...")!)
                
                // Or embed documentation
                Embed(URL(string: "https://your-docs.com")!)
            }
            """
        }
        
        ExternalLink("Showcase Repository", URL(string: "https://github.com/ipedro/swiftui-showcase")!)
        
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Embedded Web Content")
                .font(.headline)

            Text("Renders external URLs inline")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
    
    static let notes = Topic("Notes & Callouts") {
        Description {
            """
            Highlight important information with styled callout blocks. \
            Notes draw attention to warnings, deprecations, tips, and other critical details.
            
            Available note types:
            - **Note**: General informational callouts
            - **Important**: Critical information requiring attention
            - **Warning**: Potential issues or risks
            - **Deprecated**: Outdated functionality
            - **Experimental**: Beta or preview features
            - **Tip**: Best practices and recommendations
            """
        }
        
        Note(.note) {
            """
            This is a standard note callout. Use it for general information \
            that readers should be aware of.
            """
        }
        
        Note(.important) {
            """
            This is an important callout. Use it for critical information \
            that requires special attention.
            """
        }
        
        Note(.warning) {
            """
            This is a warning callout. Use it to alert users about potential \
            issues, breaking changes, or dangerous operations.
            """
        }
        
        Note(.deprecated) {
            """
            The `oldAPI()` method is deprecated. Use `newAPI()` instead for \
            better performance and additional features.
            """
        }
        
        Note(.experimental) {
            """
            This feature is experimental and may change in future releases. \
            Use with caution in production code.
            """
        }
        
        Note(.tip) {
            """
            **Pro tip**: You can use **markdown** formatting including `inline code`, \
            **bold**, and *italic* text within note content!
            """
        }
        
        CodeBlock("Usage Example") {
            """
            Topic("API Documentation") {
                Description("Overview of the API")
                
                Note(.warning) {
                    "Always call cleanup() before deallocating resources."
                }
                
                CodeBlock { "func performOperation() { ... }" }
                
                Note(.tip) {
                    "For better performance, batch multiple operations together."
                }
            }
            """
        }
        
        VStack(alignment: .leading, spacing: 12) {
            ForEach([
                ("info.circle.fill", "Note", Color.blue),
                ("exclamationmark.circle.fill", "Important", Color.purple),
                ("exclamationmark.triangle.fill", "Warning", Color.orange),
                ("xmark.octagon.fill", "Deprecated", Color.red),
                ("flask.fill", "Experimental", Color.yellow),
                ("lightbulb.fill", "Tip", Color.green)
            ], id: \.1) { icon, label, color in
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundStyle(color)
                    Text(label)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Chapter 4: Advanced Features

extension Chapter {
    static let advancedFeatures = Chapter("Advanced Features") {
        Description {
            "Master powerful capabilities for sophisticated documentation"
        }
        Topic.orderedContentRendering
        Topic.nestedTopics
        Topic.customStyles
    }
}

extension Topic {
    static let orderedContentRendering = Topic("Ordered Content Rendering") {
        Description {
            """
            Content items render in the exact order you declare them! No more fixed patterns - \
            you have complete control over your documentation layout.
            
            This is a game-changer for flexible documentation structure.
            """
        }
        
        // Demonstrate by using ordered content!
        CodeBlock("Before: Fixed Order") {
            """
            // Old behavior (before ordered content):
            Topic("Example") {
                Description("...")      // Always first
                ExternalLink(...)       // Then links (grouped)
                ExternalLink(...)
                CodeBlock { ... }       // Then code (grouped)
                Example { ... }         // Finally examples (grouped)
            }
            // Rendered: Description → Links → Examples → Code
            """
        }
        
        CodeBlock("After: Your Order") {
            """
            // New behavior (with ordered content):
            Topic("Example") {
                CodeBlock { ... }       // Code first! ✨
                Description("...")      // Then explain
                Example { ... }         // Show result
                ExternalLink(...)       // Add reference
                Embed(...)              // External content
            }
            // Renders in DECLARATION ORDER! 🎉
            """
        }
        
        VStack(alignment: .leading, spacing: 16) {
            Label("1. Code Block", systemImage: "curlybraces")
            Label("2. Description", systemImage: "text.alignleft")
            Label("3. Example", systemImage: "play.rectangle")
            Label("4. External Link", systemImage: "link")
            Label("5. Embed", systemImage: "globe")
        }
        .font(.subheadline)
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)

        Description {
            """
            This flexibility allows you to:
            - Show code before explanation (code-first approach)
            - Alternate between examples and descriptions
            - Group related content logically
            - Create unique layouts for different topics
            """
        }
        
        ExternalLink("Implementation Details", URL(string: "https://github.com/ipedro/swiftui-showcase")!)
    }
    
    static let nestedTopics = Topic("Nested Topics") {
        Description {
            """
            Create deep hierarchies by nesting topics within topics. \
            Perfect for organizing complex documentation with multiple levels of detail.
            
            Navigation automatically handles deep nesting with proper breadcrumbs and back navigation.
            """
        }
        
        CodeBlock {
            """
            Topic("UI Components") {
                Topic("Buttons") {
                    Description("Button variants and styles")
                    
                    Topic("Primary Button") {
                        CodeBlock { "Button(\\"Submit\\") { }" }
                        Button("Submit") { }.buttonStyle(.borderedProminent)
                    }
                    
                    Topic("Secondary Button") {
                        CodeBlock { "Button(\\"Cancel\\") { }" }
                        Button("Cancel") { }.buttonStyle(.bordered)
                    }
                }
                
                Topic("Forms") {
                    Topic("Text Fields") { ... }
                    Topic("Pickers") { ... }
                }
            }
            """
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Group {
                Text("Level 1: UI Components")
                    .font(.headline)

                Text("  Level 2: Buttons")
                    .font(.subheadline)
                    .padding(.leading, 12)

                Text("    Level 3: Primary Button")
                    .font(.caption)
                    .padding(.leading, 24)

                Text("    Level 3: Secondary Button")
                    .font(.caption)
                    .padding(.leading, 24)

                Text("  Level 2: Forms")
                    .font(.subheadline)
                    .padding(.leading, 12)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    static let customStyles = Topic("Custom Styles") {
        Description {
            """
            Customize the appearance of Showcase components using SwiftUI's environment \
            and view modifiers. Create branded documentation that matches your design system.
            """
        }
        
        CodeBlock("Custom Link Style") {
            """
            struct BrandedLinkStyle: ButtonStyle {
                func makeBody(configuration: Configuration) -> some View {
                    configuration.label
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
            }
            """
        }
        
        CodeBlock("Applying Styles") {
            """
            ShowcaseNavigationStack(myDocument)
                .environment(\\.linkButtonStyle, BrandedLinkStyle())
                .tint(.purple)
            """
        }

        HStack(spacing: 20) {
            VStack {
                Text("Default")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Learn More") { }
                    .buttonStyle(.bordered)
            }

            VStack {
                Text("Custom")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Learn More") { }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
            }
        }
        .padding()

        ExternalLink("Customization Guide", URL(string: "https://github.com/ipedro/swiftui-showcase#customization")!)
    }
}

#Preview {
    Document.showcaseGuide
}
