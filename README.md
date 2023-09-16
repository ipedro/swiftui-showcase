# Showcase

![Swift](https://img.shields.io/badge/Swift-5.7-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15%2B-blue.svg)
[![GitHub License](https://img.shields.io/github/license/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/network/members)

Showcase is a Swift package designed to simplify the process of documenting and showcasing SwiftUI-based components. It provides a structured approach to create, organize, and present documentation for your SwiftUI projects. Showcase offers a variety of customization options and styles for presenting code samples, previews, and more.

## Features

- Structured documentation for SwiftUI components.
- Showcase your SwiftUI views' previews.
- Showcase libraries and chapters for organized content.
- Link external resources or documentation.
- Display code samples with syntax highlighting.
- Various styles for code blocks, previews, and external links.


## Requirements

- iOS 15+
- Xcode 13+
- Swift 5.7+

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
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            // Create a list with two chapters
            ShowcaseList(
                Chapter("Section 1", .card, .accordion),
                Chapter("Section 2", .button, .text)
            )
            .navigationTitle("Component Showcase")
        }
    }
}
```

### ShowcaseNavigationView

The `ShowcaseNavigationView` view provides navigation to chapters of showcase topics. Here's an example:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        // Create a ShowcaseNavigationView with a Chapter and optional icon
        ShowcaseNavigationView(
            ShowcaseChapter(
                "My Chapter", 
                Chapter("Section 1", .card, .accordion),
                Chapter("Section 2", .button, .text)
            )
        )
    }
}
```

<!--## Documentation-->

<!--For detailed documentation and examples, please visit the [Showcase Wiki](https://github.com/ipedro/swiftui-showcase/wiki).-->

## License

Showcase is released under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please see our [Contribution Guidelines](CONTRIBUTING.md) for more information.

## Credits

Showcase is created and maintained by [Pedro Almeida](https://x.com/ipedro).
