// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OCLogger",
    products: [
        .library(
            name: "OCLogger",
            targets: ["OCLogger"]),
    ],
    targets: [
        .target(
            name: "OCLogger",
            dependencies: [],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "OCLoggerTests",
            dependencies: ["OCLogger"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
