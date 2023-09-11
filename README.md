# Showcase

![Swift](https://img.shields.io/badge/Swift-5.7-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15%2B-blue.svg)
[![GitHub License](https://img.shields.io/github/license/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/blob/main/LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/ipedro/swiftui-showcase)](https://github.com/ipedro/swiftui-showcase/network/members)

Showcase is a Swift package designed to simplify the process of documenting and showcasing SwiftUI-based components. It provides a structured approach to create, organize, and present documentation for your SwiftUI projects. Showcase offers a variety of customization options and styles for presenting code samples, previews, and more.

## Features

- Structured documentation for SwiftUI components.
- Showcase libraries and sections for organized content.
- Various styles for code blocks, previews, and external links.
- Compatible with iOS 15 and later.

## Installation

To integrate Showcase into your Xcode project, you can use Swift Package Manager (SPM):

1. Open your Xcode project.
2. Go to "File" -> "Swift Packages" -> "Add Package Dependency..."
3. Enter the repository URL: `https://github.com/ipedro/swiftui-showcase`
4. Follow the prompts to complete the installation.

Alternatively, you can add Showcase as a dependency in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/ipedro/swiftui-showcase", from: "0.3.0")
]
```

## Usage

1. Import Showcase into your Swift file:

```swift
import Showcase
```

2. Start creating structured documentation topics using the provided components and styles.

```swift
let myComponentDocumentation = DocumentationTopic {
    // Define your documentation here using the Showcase components and styles.
}
```

3. Customize the styles and layouts to match your project's needs.

## Example

Check out the `Examples` directory for a sample project demonstrating how to use Showcase for SwiftUI documentation and showcasing.

## License

Showcase is available under the MIT License. See the [LICENSE](https://github.com/ipedro/swiftui-showcase/blob/main/LICENSE) file for more details.

- Email: [your.email@example.com](mailto:your.email@example.com)

```
