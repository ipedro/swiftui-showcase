// swift-tools-version: 6.0

import CompilerPluginSupport
import PackageDescription

let isDevelopment = !Context.packageDirectory.contains("/checkouts/")

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/JohnSundell/Splash", from: "0.16.0"),
    .package(url: "https://github.com/nathantannar4/Engine", from: "2.3.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax", from: "600.0.0")
]

var plugins: [Target.PluginUsage] = []

if isDevelopment {
    dependencies += [
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.58.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.54.0")
    ]

    plugins += [
        .plugin(
            name: "SwiftLintBuildToolPlugin",
            package: "SwiftLintPlugins"
        )
    ]
}

let package = Package(
    name: "swiftui-showcase",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
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
            name: "ShowcaseMacros",
            targets: ["ShowcaseMacros"]
        )
    ],
    dependencies: dependencies,
    targets: [
        .target(
            name: "Showcase",
            dependencies: [
                "Splash",
                "Engine",
                .product(name: "EngineMacros", package: "Engine")
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport"),
                .swiftLanguageMode(.v5)
            ],
            plugins: plugins
        ),
        
        // MARK: - Macros
        
        .macro(
            name: "ShowcaseMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        
        .target(
            name: "ShowcaseMacros",
            dependencies: [
                "Showcase",
                "ShowcaseMacrosPlugin"
            ]
        ),
        
        // MARK: - Tests
        
        .testTarget(
            name: "ShowcaseTests",
            dependencies: [
                "Showcase"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
        
        .testTarget(
            name: "ShowcaseMacrosTests",
            dependencies: [
                "ShowcaseMacros",
                "ShowcaseMacrosPlugin",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
