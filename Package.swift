// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "GoldenRatioConfetti",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "GoldenRatioConfetti",
            targets: ["GoldenRatioConfetti"]
        ),
    ],
    targets: [
        .target(
            name: "GoldenRatioConfetti",
            resources: [
                .process("Particles"),
            ]
        ),
    ]
)
