// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swiftui-showcase",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "Showcase",
            type: .dynamic,
            targets: ["Showcase"]
        ),
        .library(
            name: "Showcase-auto",
            targets: ["Showcase"]
        ),
        .library(
            name: "DynamicValuePicker",
            targets: ["DynamicValuePicker"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.16.0"),
    ],
    targets: [
        .target(
            name: "Showcase",
            dependencies: ["Splash"]
        ),
        .target(name: "DynamicValuePicker"),
        .testTarget(
            name: "ShowcaseTests",
            dependencies: ["Showcase"]
        ),
    ]
)
