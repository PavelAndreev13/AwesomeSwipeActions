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
            path: "AwesomeSwipeActions"
            // .docc catalogue in this directory is picked up automatically by DocC.
        )
    ]
)
