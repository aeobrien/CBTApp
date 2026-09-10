// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Features", targets: ["Features"])
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Data"),
        .package(path: "../Services"),
        .package(path: "../DesignSystem"),
        .package(path: "../Utilities")
    ],
    targets: [
        .target(
            name: "Features",
            dependencies: ["Domain", "Data", "Services", "DesignSystem", "Utilities"]
        ),
        .testTarget(name: "FeaturesTests", dependencies: ["Features"])
    ]
)
