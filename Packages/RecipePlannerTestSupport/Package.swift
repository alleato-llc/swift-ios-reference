// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RecipePlannerTestSupport",
    platforms: [
        .macOS(.v15),
        .iOS(.v26),
    ],
    products: [
        .library(name: "RecipePlannerTestSupport", targets: ["RecipePlannerTestSupport"]),
    ],
    dependencies: [
        .package(path: "../RecipePlannerCore"),
        .package(path: "../RecipePlannerServices"),
    ],
    targets: [
        .target(
            name: "RecipePlannerTestSupport",
            dependencies: ["RecipePlannerCore", "RecipePlannerServices"],
            path: "Sources/RecipePlannerTestSupport"
        ),
    ]
)
