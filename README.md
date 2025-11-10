# Showcase

<div align="center">

[![CI](https://github.com/ipedro/swiftui-showcase/actions/workflows/ci.yml/badge.svg)](https://github.com/ipedro/swiftui-showcase/actions/workflows/ci.yml)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://www.swift.org/documentation/)
![iOS](https://img.shields.io/badge/iOS-16%2B-blue.svg)
![macOS](https://img.shields.io/badge/macOS-13%2B-lightgrey.svg)
[![GitHub License](https://img.shields.io/github/license/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/network/members)

</div>

Showcase is a Swift package designed to simplify the process of documenting and showcasing SwiftUI-based components. It provides a structured approach to create, organize, and present documentation for your SwiftUI projects. Showcase offers a variety of customization options and styles for presenting code samples, previews, and more.

## Features

- Structured documentation for SwiftUI components.
- Showcase your SwiftUI views' previews.
- Showcase libraries and chapters for organized content.
- Link external resources or documentation.
- Display code samples with syntax highlighting.
- Various styles for code blocks, previews, and external links.


## Requirements

- iOS 16+
- macOS 13+
- Swift 6.0+
- Xcode 16+

## Installation

### Swift Package Manager

You can easily integrate Showcase into your Xcode project using [Swift Package Manager](https://swift.org/package-manager/). Follow these steps:

1. Open your project in Xcode.
2. Go to "File" -> "Swift Packages" -> "Add Package Dependency..."
3. Enter the following URL when prompted: https://github.com/ipedro/swiftui-showcase
4. Choose the version or branch you want to use.
5. Click "Finish" to add the package to your project.

Alternatively, you can add Showcase as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ipedro/swiftui-showcase", from: "0.3.0")
]
```

Also: Don't forget to add `"Showcase"` as a dependency of your package's target.

## Usage

1. Import the Showcase module in your SwiftUI view file:

   ```swift
   import Showcase
   ```

2. Create and structure your showcase topics using `Topic` instances.

### Showcase

The `Showcase` view is used to display your showcase topics. Here's an example:

```swift
import Showcase
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            // Create a Showcase with a Topic, e.g., .card
            Showcase(.mockCard)
                .navigationTitle("Component Showcase")
        }
    }
}
```

### ShowcaseList

The `ShowcaseList` view allows you to list chapters of showcase topics. Here's an example:

```swift
import Showcase
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            // Create a list with two chapters using the DSL builders
            ShowcaseList(
                Chapter("Section 1") {
                    Topic("Card") {
                        Description("Display content and actions in a single container.")
                    }

                    Topic("Accordion") {
                        Description("Reveal or hide related content on demand.")
                    }
                },
                Chapter("Section 2") {
                    Topic("Button") {
                        Example {
                            Button("Tap me") {}
                        }
                    }
                    
                    // New: Examples can include inline code blocks
                    Topic("Advanced Button") {
                        Example("With Source Code") {
                            Button("Submit") { }
                                .buttonStyle(.borderedProminent)
                            
                            // Show the source code inline
                            CodeBlock("Implementation") {
                                """
                                Button("Submit") { }
                                    .buttonStyle(.borderedProminent)
                                """
                            }
                        }
                    }
                }
            )
            .navigationTitle("Component Showcase")
        }
    }
}
```

### ShowcaseNavigationView

The `ShowcaseNavigationView` view provides navigation to chapters of showcase topics. Here's an example:

```swift
import Showcase
import SwiftUI

struct ContentView: View {
    var body: some View {
        // Create a navigation stack from a document composed with the DSL
        ShowcaseNavigationStack(
            Document("My Chapter") {
                Chapter("Section 1") {
                    Topic("Card") {
                        Description("Display content and actions in a single container.")
                    }

                    Topic("Button") {
                        Example {
                            Button("Tap me") {}
                        }
                    }
                }
            }
        )
    }
}
```

### Macros for Automatic Documentation

Showcase provides powerful macros to automatically generate documentation from your SwiftUI components with minimal effort.

#### @Showcasable

The `@Showcasable` macro automatically generates a `showcaseTopic` property for your types, extracting documentation from doc comments and discovering members:

```swift
import Showcase
import ShowcaseMacros

/// A card component for displaying content
///
/// Cards are versatile containers that can hold any SwiftUI content.
///
/// > Note: Always provide meaningful content to your cards
@Showcasable(icon: "rectangle.fill")
struct Card<Content: View>: View {
    /// The card's optional title
    let title: String?
    
    /// The card's content
    let content: Content
    
    /// Creates a card with optional title
    /// - Parameters:
    ///   - title: Optional title to display
    ///   - content: The card's content view
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let title {
                Text(title).font(.headline)
            }
            content
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// Usage: Card.showcaseTopic automatically includes:
// - Type description and notes from doc comments
// - Declaration with generic constraints
// - All public initializers with their documentation
// - All public properties with their documentation
```

#### @ShowcaseExample

Use `@ShowcaseExample` to define reusable examples that will be automatically discovered:

```swift
struct CardExamples {
    @ShowcaseExample(title: "Simple Card")
    static var simple: some View {
        Card(title: "Welcome") {
            Text("This is a simple card")
        }
    }
    
    @ShowcaseExample(
        title: "Card with Image",
        description: "Cards can contain any SwiftUI content"
    )
    static var withImage: some View {
        Card(title: "Photo") {
            VStack {
                Image(systemName: "photo")
                    .font(.largeTitle)
                Text("Add your photo here")
            }
        }
    }
}

// Reference in @Showcasable
@Showcasable(icon: "rectangle.fill", examples: [CardExamples.self])
struct Card<Content: View>: View {
    // ... implementation
}
```

#### @ShowcaseHidden

Hide specific members from auto-discovery:

```swift
@Showcasable
struct MyView: View {
    @ShowcaseHidden
    private var internalHelper: String = ""
    
    var body: some View {
        // Only public API will be documented
        Text("Hello")
    }
}
```

#### Benefits of Macros

- **Automatic Updates**: Documentation stays in sync with your code
- **Less Boilerplate**: No manual Topic construction needed
- **Doc Comment Integration**: Leverages existing documentation
- **Type Safety**: Compile-time validation of examples
- **Auto-Discovery**: Finds members, examples, and relationships automatically

<!--## Documentation-->

<!--For detailed documentation and examples, please visit the [Showcase Wiki](https://github.com/ipedro/swiftui-showcase/wiki).-->

## License

Showcase is released under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please see our [Contribution Guidelines](CONTRIBUTING.md) for more information.

## Credits

Showcase is created and maintained by [Pedro Almeida](https://x.com/ipedro).
