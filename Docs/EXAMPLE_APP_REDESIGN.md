# Example App Redesign Plan

## Overview
Redesign the ShowcaseExample app to be a professional, feature-complete demonstration of the Showcase framework using a meta-documentation approach (documenting Showcase with Showcase itself).

## Current State Issues
- ❌ SystemComponents.swift has many empty placeholder topics
- ❌ Mock files (Button, Card, Accordion) aren't integrated into main app
- ❌ **No Embed demonstrations** (feature exists but never shown!)
- ❌ **Ordered content feature not showcased** (the new capability)
- ❌ Looks skeletal rather than a real app
- ❌ Code examples don't show variety (languages, styles)
- ❌ Links are minimal and generic

## Recent API Updates (Completed)
- ✅ `Link` renamed to `ExternalLink`
- ✅ `Preview` renamed to `Example`
- ✅ Wrapper functions removed (`Links {}`, `Code {}`, `Preview {}`)
- ✅ Ordered content rendering implemented (items array preserves declaration order)
- ✅ All backward compatibility code removed

## New Approach: "Showcase Framework Guide"
**Concept**: Meta-documentation app that demonstrates Showcase by documenting itself
- Similar to: Storybook examples, SwiftUI documentation, component library demos
- Professional and realistic
- Every example is runnable and useful

## Document Structure

```
📱 Document: "Showcase Framework"
Description: "A declarative SwiftUI framework for creating rich component documentation"

├─ 🚀 Chapter: "Getting Started"
│  ├─ Topic: "Quick Start"
│  │  └─ Demonstrates: Code-first ordering (shows flexibility!)
│  ├─ Topic: "Installation" 
│  │  └─ Demonstrates: Links, Code blocks, Description mix
│  └─ Topic: "Basic Example"
│     └─ Demonstrates: Traditional ordering (for contrast)
│
├─ 📚 Chapter: "Core Concepts"
│  ├─ Topic: "Documents & Chapters"
│  │  └─ Demonstrates: Hierarchical structure, icons
│  ├─ Topic: "Topics"
│  │  └─ Demonstrates: Nested topics, topic hierarchy
│  └─ Topic: "Content Types"
│     └─ Demonstrates: Overview of Link, Code, Preview, Embed
│
├─ 📝 Chapter: "Content Types"
│  ├─ Topic: "External Links"
│  │  └─ Demonstrates: Multiple links, link styling
│  ├─ Topic: "Code Blocks"
│  │  └─ Demonstrates: Multiple languages, syntax highlighting
│  ├─ Topic: "Examples"
│  │  └─ Demonstrates: Live SwiftUI views, multiple examples
│  └─ Topic: "Embeds"
│     └─ Demonstrates: External content embedding (CURRENTLY NOT SHOWN!)
│
└─ ⚡ Chapter: "Advanced Features"
   ├─ Topic: "Ordered Content Rendering" ⭐ HERO FEATURE
   │  └─ Demonstrates: Before/after, flexible ordering
   ├─ Topic: "Custom Styles"
   │  └─ Demonstrates: Theming, custom ButtonStyles, custom views
   ├─ Topic: "Hierarchical Topics"
   │  └─ Demonstrates: Deep nesting, navigation
   └─ Topic: "Custom Icons"
      └─ Demonstrates: SF Symbols integration

Total: 4 chapters, 13 focused topics
```

## Key Topic Examples

### 1. "Ordered Content Rendering" (Hero Feature) ⭐

**Purpose**: Showcase the NEW ordered content feature with before/after comparison

```swift
Topic("Ordered Content Rendering") {
    Description {
        """
        Content items now render in the exact order you declare them!
        No more fixed patterns - you have complete control over layout.
        """
    }
    
    // Show old rigid pattern (before ordered content)
    CodeBlock("Before: Fixed Order") {
        """
        Topic("Example") {
            Description("...")      // Always first
            ExternalLink(...)       // Then links (grouped)
            ExternalLink(...)
            CodeBlock { ... }       // Then code (grouped)
            Example { ... }         // Finally examples (grouped)
        }
        // Rendered: Description → Links → Examples → Code (fixed order)
        """
    }
    
    // Show new flexible pattern (with ordered content)
    CodeBlock("After: Your Order") {
        """
        Topic("Example") {
            CodeBlock { ... }       // Code first!
            Description("...")      // Then explain
            Example { ... }         // Show result
            ExternalLink(...)       // Reference
            Embed(...)              // External content
        }
        // Renders in DECLARATION ORDER! 🎉
        """
    }
    
    // Live example showing flexible ordering
    Example {
        VStack(alignment: .leading, spacing: 16) {
            Label("1. Code Block", systemImage: "curlybraces")
            Label("2. Description", systemImage: "text.alignleft")
            Label("3. Example", systemImage: "play.rectangle")
            Label("4. External Link", systemImage: "link")
            Label("5. Embed", systemImage: "globe")
        }
        .font(.subheadline)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    // Link to implementation details
    ExternalLink("View Implementation Details", URL(string: "https://github.com/ipedro/swiftui-showcase")!)
}
```

### 2. "Embeds" Topic (Currently Missing!) 🆕

**Purpose**: Demonstrate Embed which exists but is never shown

```swift
Topic("External Embeds") {
    Description {
        """
        Embed external web content directly in your documentation.
        Perfect for design specs, live demos, or reference materials.
        """
    }
    
    // Link to the Showcase repository
    ExternalLink("Showcase Repository", URL(string: "https://github.com/ipedro/swiftui-showcase")!)
    
    // Embed the repository page
    Embed(URL(string: "https://github.com/ipedro/swiftui-showcase")!)
    
    CodeBlock("Usage") {
        """
        Embed(URL(string: "https://example.com")!)
        """
    }
    
    Example {
        VStack {
            Image(systemName: "network")
                .font(.system(size: 48))
            Text("External Content")
                .font(.headline)
            Text("Embeds render web content inline")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
```

### 3. "Quick Start" (Non-traditional Order) 🚀

**Purpose**: Show that code can come FIRST - breaking traditional patterns

```swift
Topic("Quick Start") {
    // CODE FIRST! (showing flexibility with ordered content)
    CodeBlock("Basic Example") {
        """
        import Showcase
        
        ShowcaseNavigationStack(
            Document("My App") {
                Chapter("Components") {
                    Topic("Button") {
                        Description("A tappable control")
                        
                        CodeBlock {
                            "Button(\\"Tap Me\\") { }"
                        }
                        
                        Example {
                            Button("Tap Me") { }
                        }
                    }
                }
            }
        )
        """
    }
    
    // Then explain what it does
    Description {
        """
        This creates a complete documentation structure with a document,
        chapter, and topic. The DSL makes it easy to organize and present
        your components.
        """
    }
    
    // Show the result
    Example {
        VStack(alignment: .leading, spacing: 8) {
            Text("📱 Document: My App")
                .font(.headline)
            Text("  📚 Chapter: Components")
                .font(.subheadline)
            Text("    📝 Topic: Button")
                .font(.caption)
        }
        .padding()
    }
    
    // Link to full docs
    ExternalLink("Full Documentation", URL(string: "https://github.com/ipedro/swiftui-showcase#readme")!)
}
```

### 4. "Code Blocks" (Multiple Languages)

**Purpose**: Show syntax highlighting and multiple code blocks

```swift
Topic("Code Blocks") {
    Description("Display syntax-highlighted code examples in multiple languages")
    
    CodeBlock("Swift") {
        """
        struct ContentView: View {
            var body: some View {
                Text("Hello, World!")
            }
        }
        """
    }
    
    CodeBlock("JSON") {
        """
        {
            "name": "Showcase",
            "version": "1.0.0",
            "description": "SwiftUI documentation framework"
        }
        """
    }
    
    CodeBlock("Markdown") {
        """
        # Showcase Framework
        
        A **declarative** DSL for creating *beautiful* documentation.
        """
    }
    
    Example {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "swift")
                Text("Swift")
            }
            HStack {
                Image(systemName: "doc.text")
                Text("JSON")
            }
            HStack {
                Image(systemName: "text.alignleft")
                Text("Markdown")
            }
        }
        .padding()
    }
}
```

### 5. "Custom Styles" (Theming & Customization) 🎨

**Purpose**: Show users how to create custom visual styles for Showcase components

```swift
Topic("Custom Styles") {
    Description {
        """
        Customize the appearance of Showcase components using SwiftUI's
        environment and view modifiers. Create branded documentation that
        matches your design system.
        """
    }
    
    // Example: Custom link style
    CodeBlock("Custom Link Style") {
        """
        struct BrandedLinkStyle: ButtonStyle {
            func makeBody(configuration: Configuration) -> some View {
                configuration.label
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
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            }
        }
        """
    }
    
    // Show how to apply custom styles
    CodeBlock("Applying Styles") {
        """
        ShowcaseNavigationStack(myDocument)
            .environment(\\.linkButtonStyle, BrandedLinkStyle())
            .environment(\\.codeBlockTheme, .dracula)
            .tint(.purple)
        """
    }
    
    // Example showing before/after
    Example {
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
    }
    
    // More advanced: Custom code block theme
    CodeBlock("Custom Code Theme") {
        """
        // Define your own syntax highlighting colors
        extension CodeBlockTheme {
            static let myBrand = CodeBlockTheme(
                keyword: .purple,
                string: .green,
                number: .orange,
                comment: .gray,
                background: .black.opacity(0.05)
            )
        }
        """
    }
    
    // Link to customization guide
    ExternalLink("Customization Guide", URL(string: "https://github.com/ipedro/swiftui-showcase#customization")!)
    
    // Nested topic for specific components
    Topic("Code Block Styles") {
        Description("Customize syntax highlighting themes for code blocks")
        
        CodeBlock("Available Themes") {
            """
            .environment(\\.codeBlockTheme, .xcode)      // Light theme
            .environment(\\.codeBlockTheme, .dracula)    // Dark theme
            .environment(\\.codeBlockTheme, .solarized)  // Neutral theme
            .environment(\\.codeBlockTheme, .myBrand)    // Your custom theme
            """
        }
        
        Example {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(["Xcode", "Dracula", "Solarized", "Custom"], id: \\.self) { theme in
                    HStack {
                        Circle()
                            .fill(theme == "Xcode" ? .blue : theme == "Dracula" ? .purple : theme == "Solarized" ? .orange : .green)
                            .frame(width: 12, height: 12)
                        Text(theme)
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
    }
}
```

## Real Content to Include

### Links
- ✅ GitHub Repository: `https://github.com/ipedro/swiftui-showcase`
- ✅ PR #12 (Ordered Content): `https://github.com/ipedro/swiftui-showcase/pull/12`
- ✅ Apple SwiftUI Docs: `https://developer.apple.com/documentation/swiftui/`
- ✅ Apple HIG: `https://developer.apple.com/design/human-interface-guidelines/`

### Embeds
- ✅ Showcase repository page
- ✅ Apple SwiftUI documentation
- ⚠️ Consider: SwiftUI tutorial video (if relevant and appropriate)

### Code Examples
- ✅ All examples use actual Showcase API
- ✅ Show multiple languages (Swift, JSON, Markdown)
- ✅ Every code example is valid and runnable

### Previews
- ✅ Live SwiftUI views demonstrating concepts
- ✅ Visual hierarchy examples
- ✅ Before/after comparisons

## Implementation Steps

### Phase 1: Core Structure
1. Create `ShowcaseExample/Mocks/ShowcaseGuide.swift`
2. Define document, chapters, and topic stubs
3. Update `ContentView.swift` to use new `.showcaseGuide` document

### Phase 2: Key Topics (Priority Order)
1. **"Ordered Content Rendering"** - The hero feature (MUST DO FIRST)
2. **"Embeds"** - Show missing capability
3. **"Quick Start"** - Demonstrate code-first ordering
4. **"Code Blocks"** - Show language variety
5. Fill in remaining topics progressively

### Phase 3: Content & Polish
1. Add all real links and embeds
2. Create working preview views
3. Add SF Symbols icons to all chapters
4. Ensure all code examples compile
5. Test navigation and hierarchy

### Phase 4: Cleanup
1. Decide what to do with existing mock files
   - Option A: Delete MockButton, MockCard, MockAccordion
   - Option B: Keep in separate folder as "Alternative Examples"
2. Update README if needed
3. Screenshots for documentation

## Success Criteria

✅ Every Showcase feature is demonstrated at least once  
✅ Ordered content feature is prominently showcased  
✅ Topic.Embed is demonstrated (currently missing!)  
✅ App looks professional and realistic  
✅ All code examples are valid and runnable  
✅ Navigation is smooth and hierarchical  
✅ Content is useful as actual Showcase documentation  

## Files to Create/Modify

### New Files
- `ShowcaseExample/Mocks/ShowcaseGuide.swift` (main content)

### Modified Files  
- `ShowcaseExample/ContentView.swift` (point to new document)

### Files to Consider Removing
- `MockButton.swift` (or move to archive)
- `MockCard.swift` (or move to archive)
- `MockAccordion.swift` (or move to archive)
- `SystemComponents.swift` (replace with ShowcaseGuide.swift)

## Timeline
- **Prerequisite**: Complete API rename (Link → ExternalLink, etc.)
- **Estimated effort**: 4-6 hours for complete implementation
- **Priority**: High - this is the public face of the framework

## Notes
- Meta-documentation approach is industry standard (Storybook, SwiftUI docs)
- Focus on quality over quantity (12 rich topics > 50 empty ones)
- Every example should be directly useful to Showcase users
- The ordered content feature is the HERO - showcase it prominently
