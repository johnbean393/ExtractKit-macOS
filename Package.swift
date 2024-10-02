// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExtractKit-macOS",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ExtractKit-macOS",
            targets: ["ExtractKit-macOS"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ExtractKit-macOS"),
        .testTarget(
            name: "ExtractKit-macOSTests",
            dependencies: ["ExtractKit-macOS"]
        ),
    ]
)
