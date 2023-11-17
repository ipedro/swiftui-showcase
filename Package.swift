// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swiftui-showcase",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Showcase",
            targets: ["Showcase"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.16.0"),
    ],
    targets: [
        .target(
            name: "Showcase",
            dependencies: ["Splash"]
        ),
        .testTarget(
            name: "ShowcaseTests",
            dependencies: ["Showcase"]
        ),
    ]
)
