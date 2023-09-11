# Showcase

[![Swift Version](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![GitHub Actions](https://github.com/ipedro/swiftui-showcase/workflows/Swift/badge.svg)](https://github.com/ipedro/swiftui-showcase/actions)

Showcase is a Swift package for SwiftUI that allows you to create documentation and showcase your SwiftUI components, providing a seamless way to present your UI elements with code samples, previews, and more.

## Features

- Organize and present SwiftUI components.
- Display code samples with syntax highlighting.
- Showcase previews of your SwiftUI views.
- Link to external resources or documentation.
- Easily customize the presentation style.

## Requirements

- iOS 15+
- Xcode 13+
- Swift 5.5+

## Installation

### Swift Package Manager

You can easily integrate Showcase into your Xcode project using [Swift Package Manager](https://swift.org/package-manager/). Follow these steps:

1. Open your project in Xcode.
2. Go to "File" -> "Swift Packages" -> "Add Package Dependency..."
3. Enter the following URL when prompted: https://github.com/ipedro/swiftui-showcase
4. Choose the version or branch you want to use.
5. Click "Finish" to add the package to your project.

### Manual

You can also manually integrate Showcase into your project by copying the source files into your Xcode project.

## Usage

1. Import the Showcase module in your SwiftUI view file:

   ```swift
   import Showcase
   ```

2. Create and structure your showcase elements using `ShowcaseElement` instances.

### Showcase

The `Showcase` view is used to display your showcase elements. Here's an example:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            // Create a Showcase with a ShowcaseElement, e.g., .card
            Showcase(.card)
                .navigationTitle("Component Showcase")
        }
    }
}
```

### ShowcaseList

The `ShowcaseList` view allows you to list sections of showcase elements. Here's an example:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            // Create a list with two sections
            ShowcaseList(
                ShowcaseSection("Section 1", .card, .accordion),
                ShowcaseSection("Section 2", .button, .text)
            )
            .navigationTitle("Component Showcase")
        }
    }
}
```

### ShowcaseNavigationView

The `ShowcaseNavigationView` view provides navigation to sections of showcase elements. Here's an example:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        // Create a ShowcaseNavigationView with a ShowcaseLibrary and optional icon
        ShowcaseNavigationView(
            ShowcaseLibrary(
                "My Library", 
                ShowcaseSection("Section 1", .card, .accordion),
                ShowcaseSection("Section 2", .button, .text)
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
