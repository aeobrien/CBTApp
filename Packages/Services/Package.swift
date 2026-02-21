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
        .package(path: "../Utilities"),
        .package(url: "https://github.com/argmaxinc/WhisperKit.git", from: "0.15.0")
    ],
    targets: [
        .target(name: "Services", dependencies: [
            "Domain",
            "Utilities",
            .product(name: "WhisperKit", package: "WhisperKit")
        ]),
        .testTarget(name: "ServicesTests", dependencies: ["Services"])
    ]
)
