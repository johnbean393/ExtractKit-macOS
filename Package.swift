// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExtractKit-macOS",
	platforms: [
		.macOS(.v15)
	],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ExtractKit-macOS",
            targets: ["ExtractKit-macOS"]),
    ],
	dependencies: [
		.package(url: "https://github.com/johnbean393/FSKit-macOS", branch: "main"),
		.package(url: "https://github.com/scinfu/SwiftSoup", .upToNextMajor(from: "2.6.0")),
		.package(url: "https://github.com/swiftcsv/SwiftCSV", .upToNextMajor(from: "0.10.0")),
		.package(url: "https://github.com/CoreOffice/CoreXLSX.git", .upToNextMinor(from: "0.14.1")),
	],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ExtractKit-macOS",
			dependencies: [
				.product(name: "FSKit-macOS", package: "FSKit-macOS"),
				.product(name: "SwiftSoup", package: "SwiftSoup"),
				.product(name: "SwiftCSV", package: "SwiftCSV"),
				.product(name: "CoreXLSX", package: "CoreXLSX"),
			]
		),
		.testTarget(
			name: "ExtractKit-macOSTests",
			dependencies: ["ExtractKit-macOS"]
		),
    ]
)
