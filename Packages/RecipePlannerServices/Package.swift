// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "RecipePlannerServices",
    platforms: [
        .macOS(.v15),
        .iOS(.v26),
    ],
    products: [
        .library(name: "RecipePlannerServices", targets: ["RecipePlannerServices"]),
    ],
    dependencies: [
        .package(path: "../RecipePlannerCore"),
        .package(path: "../RecipePlannerTestSupport"),
    ],
    targets: [
        .target(
            name: "RecipePlannerServices",
            dependencies: ["RecipePlannerCore"],
            path: "Sources/RecipePlannerServices"
        ),
        .testTarget(
            name: "RecipePlannerServicesTests",
            dependencies: [
                "RecipePlannerServices",
                .product(name: "RecipePlannerTestSupport", package: "RecipePlannerTestSupport"),
            ],
            path: "Tests/RecipePlannerServicesTests"
        ),
    ]
)
