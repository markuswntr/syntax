// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Syntax",
    products: [
        .library(name: "Syntax", targets: ["Syntax"])
    ],
    targets: [
        .target(name: "Syntax", dependencies: []),
        .testTarget(name: "SyntaxTests", dependencies: ["Syntax"])
    ]
)
