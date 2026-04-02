// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AwesomeSwipeAction",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),       // macOS 14 — full SwiftUI parity with the iOS target
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "AwesomeSwipeAction",
            targets: ["AwesomeSwipeAction"]
        )
    ],
    targets: [
        .target(
            name: "AwesomeSwipeAction",
            path: "AwesomeSwipeAction"
            // .docc catalogue in this directory is picked up automatically by DocC.
        )
    ]
)
