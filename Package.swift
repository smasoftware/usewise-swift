// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UsewiseSwift",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(name: "UsewiseSwift", targets: ["UsewiseSwift"]),
    ],
    targets: [
        .target(
            name: "UsewiseSwift",
            path: "Sources/UsewiseSwift"
        ),
        .testTarget(
            name: "UsewiseSwiftTests",
            dependencies: ["UsewiseSwift"],
            path: "Tests/UsewiseSwiftTests"
        ),
    ]
)
