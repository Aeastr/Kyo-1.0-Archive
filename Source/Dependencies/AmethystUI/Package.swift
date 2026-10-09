// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmethystUI",
    platforms: [.iOS("16.0"), .macOS(.v14), .visionOS(.v1)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AmethystUI",
            targets: ["AmethystUI"]),
    ],
    dependencies: [
        .package(name: "RiveRuntime", url: "https://github.com/rive-app/rive-ios.git", .upToNextMajor(from: "5.1.6"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AmethystUI",
            dependencies: [.product(name: "RiveRuntime", package: "RiveRuntime", condition: .when(platforms: [.macOS, .iOS]))],
            resources: [
                            .copy("ExampleResources"), // Update the resource path
                            .copy("Resources/Fonts"),
                            .copy("Resources/Images")
                        ]
        ),
        .testTarget(
            name: "AmethystUITests",
            dependencies: ["AmethystUI", "RiveRuntime"])
    ]
)

