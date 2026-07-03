// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GoldenRatioConfetti",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
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
