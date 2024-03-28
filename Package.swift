// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "SUIBridge",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "SUIBridge",
            targets: ["SUIBridge"])
    ],
    targets: [
        .target(
            name: "SUIBridge"),
        .testTarget(
            name: "SUIBridgeTests",
            dependencies: ["SUIBridge"])
    ]
)
