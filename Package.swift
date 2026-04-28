// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AwesomeSwipeActions",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),       // macOS 14 — full SwiftUI parity with the iOS target
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AwesomeSwipeActions",
            targets: ["AwesomeSwipeActions"]
        )
    ],
    targets: [
        .target(
            name: "AwesomeSwipeActions",
            path: "AwesomeSwipeActions",
            // The .docc catalogue inside this directory is picked up automatically.
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableUpcomingFeature("InferSendableFromCaptures")
            ]
        ),
        .testTarget(
            name: "AwesomeSwipeActionsTests",
            dependencies: ["AwesomeSwipeActions"],
            path: "Tests/AwesomeSwipeActionsTests"
        )
    ]
)
