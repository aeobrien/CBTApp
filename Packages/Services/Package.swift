// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Services", targets: ["Services"])
    ],
    dependencies: [
        .package(path: "../Domain"),
        .package(path: "../Utilities")
    ],
    targets: [
        .target(name: "Services", dependencies: ["Domain", "Utilities"]),
        .testTarget(name: "ServicesTests", dependencies: ["Services"])
    ]
)
