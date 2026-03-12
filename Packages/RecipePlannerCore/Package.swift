// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RecipePlannerCore",
    platforms: [
        .macOS(.v15),
        .iOS(.v26),
    ],
    products: [
        .library(name: "RecipePlannerCore", targets: ["RecipePlannerCore"]),
    ],
    targets: [
        .target(
            name: "RecipePlannerCore",
            path: "Sources/RecipePlannerCore"
        ),
    ]
)
