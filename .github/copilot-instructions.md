# Showcase - SwiftUI Component Documentation Framework

## Project Architecture

This is a **Swift Package** for iOS/macOS (iOS 16+, macOS 13+) that provides a declarative DSL for documenting SwiftUI components. The package uses result builders extensively to create documentation structures.

### Core Hierarchy
```
Document → Chapter → Topic → [CodeBlock, Preview, Link, Embed]
```

- **Document**: Top-level container (via `ShowcaseNavigationStack` or `ShowcaseList`)
- **Chapter**: Groups related topics with title, icon, description
- **Topic**: Individual component documentation with code examples, previews, links
- **Sub-components**: CodeBlock (syntax-highlighted code), Preview (live SwiftUI views), Link (external URLs), Embed (external content)

### Key Files
- `Sources/Showcase/Models/Topic/Topic.swift` - Core model using `@Lazy` property wrapper for optional properties
- `Sources/Showcase/Models/Topic/TopicBuilder.swift` - Result builder for declarative topic creation
- `Sources/Showcase/Views/Topic/ShowcaseTopic.swift` - Main view component that renders topics
- `Sources/Showcase/Helpers/Lazy.swift` - Custom property wrapper for lazy initialization (used extensively)

## Critical Patterns

### 1. `@Lazy` Property Wrapper Pattern
All optional/expensive properties in models use `@Lazy` instead of standard lazy vars:
```swift
@Lazy public var description: String
@Lazy public var icon: Image?
@Lazy public var previews: [Preview]
```
This custom wrapper (see `Lazy.swift`) provides cached lazy initialization. Always use `@Lazy` for Topic/Chapter/CodeBlock properties, never standard Swift lazy vars.

### 2. Result Builder DSL
Every model has a companion result builder for declarative syntax:
- `TopicBuilder` for topics
- `CodeBlockBuilder` for code blocks  
- `PreviewBuilder` for previews
- `LinkBuilder` for links
- `EmbedBuilder` for embeds

When adding new models, follow this pattern: create `ModelName.swift` and `ModelNameBuilder.swift`.

### 3. View Composition Strategy
Views follow a strict naming convention:
- `Showcase[Component]` for the main view (e.g., `ShowcaseTopic`, `ShowcaseCodeBlock`)
- Configuration structs named `Showcase[Component]Configuration`
- Use `EquatableForEach` (custom helper) instead of standard ForEach for better performance

### 4. Package Structure
- `Sources/Showcase/` - Public library code
- `ShowcaseExample/` - Separate Xcode project for testing/development
- Mocks live in `ShowcaseExample/ShowcaseExample/Mocks/` - reference these for examples

## Development Workflow

### AI-Assisted Development (MCP Integration)
This project includes `.vscode/mcp.json` configuration for the **xcodebuildmcp2** Model Context Protocol server. AI assistants with MCP support can use this to:

- **Build the package**: Use `mcp_xcodebuildmcp2_swift_package_build` instead of `swift build`
- **Run tests**: Use `mcp_xcodebuildmcp2_swift_package_test` instead of `swift test`
- **Discover projects**: Use `mcp_xcodebuildmcp2_discover_projs` to find Xcode projects/workspaces
- **List schemes**: Use `mcp_xcodebuildmcp2_list_schemes` to enumerate available build schemes
- **Access build settings**: Use `mcp_xcodebuildmcp2_show_build_settings` for configuration inspection

Benefits:
- No need to manually run terminal commands
- Automated test execution with detailed results
- Direct integration with Xcode tooling
- AI can verify changes by running tests programmatically

When an AI assistant is available with MCP support, prefer using these tools over terminal commands for Swift Package operations.

**Important**: Only push commits when explicitly requested. Use `git add` and `git commit` freely, but wait for user confirmation before running `git push`.

### Building & Testing (Traditional)
```bash
# Build the package
swift build

# Run tests
swift test

# Open example app
open ShowcaseExample/ShowcaseExample.xcodeproj
```

### Adding New Components
1. Create model in `Sources/Showcase/Models/[ComponentName]/`
2. Add result builder for declarative syntax
3. Create view in `Sources/Showcase/Views/[ComponentName]/`
4. Add mock in `ShowcaseExample/ShowcaseExample/Mocks/`
5. Use `@Lazy` for all optional/expensive properties

### Dependencies
- **Splash** (0.16.0+): Syntax highlighting for code blocks
- **Engine** (2.0.1+): UI utilities
- **SwiftLint/SwiftFormat**: Development-only (via `isDevelopment` flag in Package.swift)

Linting only runs when package is not in `checkouts/` directory (i.e., during development).

## Key Conventions

1. **Copyright Headers**: All files include full MIT license header with Pedro Almeida attribution
2. **File Organization**: Mirror structure between Sources/Showcase and ShowcaseExample for parallel development
3. **Environment Values**: Custom environment keys in `Sources/Showcase/Environment/` (e.g., `nodeDepth` for hierarchical rendering)
4. **Equatable Conformance**: Models and views implement Equatable for performance optimization
5. **Public API**: All public types/methods documented with triple-slash comments

## Integration Points

- **SwiftUI Previews**: Topic.Preview model wraps any SwiftUI view for live preview display
- **Syntax Highlighting**: Splash library handles code formatting; configure language via CodeBlock model
- **Navigation**: Use `ShowcaseNavigationStack` for single document or `ShowcaseList` for multi-chapter navigation

## Common Tasks

**Add a new Topic extension method** → Follow pattern in `Sources/Showcase/Models/Topic/Topic+[Feature].swift`
**Modify rendering** → Update view in `Sources/Showcase/Views/[Component]/Showcase[Component].swift`
**Add mock data** → Place in `ShowcaseExample/ShowcaseExample/Mocks/Mock[Component].swift`
**Update DSL** → Modify corresponding `*Builder.swift` result builder
