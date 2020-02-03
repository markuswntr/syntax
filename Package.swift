// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Syntax",
    products: [
        .library(name: "Syntax", targets: ["Syntax"]),
    ],
    targets: [
        .target(name: "Syntax", dependencies: []),
        .testTarget(name: "SyntaxTests", dependencies: ["Syntax"]),
        // The following test may be used as example
        .testTarget(name: "MarkdownTests", dependencies: ["Syntax"]),
    ]
)
