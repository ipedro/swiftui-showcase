// swift-tools-version: 6.0

import CompilerPluginSupport
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
            targets: ["Showcase"]
        ),
        .library(
            name: "ShowcaseMacros",
            targets: ["ShowcaseMacros"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Splash", from: "0.16.0"),
        .package(url: "https://github.com/nathantannar4/Engine", from: "2.3.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", from: "602.0.0")
    ],
    targets: [
        .target(
            name: "Showcase",
            dependencies: [
                "Splash",
                "Engine",
                .product(name: "EngineMacros", package: "Engine"),
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
            ]
        ),

        // MARK: - Macros

        .macro(
            name: "ShowcaseMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),

        .target(
            name: "ShowcaseMacros",
            dependencies: [
                "Showcase",
                "ShowcaseMacrosPlugin",
            ]
        ),

        // MARK: - Tests

        .testTarget(
            name: "ShowcaseTests",
            dependencies: [
                "Showcase",
            ]
        ),
        .testTarget(
            name: "ShowcaseMacrosTests",
            dependencies: [
                "ShowcaseMacros",
                "ShowcaseMacrosPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
