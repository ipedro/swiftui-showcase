// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swiftui-showcase",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
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
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.16.0"),
        .package(url: "https://github.com/nathantannar4/Engine", from: "1.8.2"),
    ],
    targets: [
        .target(
            name: "Showcase",
            dependencies: [
                "Splash",
                "Engine",
                .product(name: "EngineMacros", package: "Engine"), // Optional
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "ShowcaseTests",
            dependencies: ["Showcase"]
        ),
    ]
)
