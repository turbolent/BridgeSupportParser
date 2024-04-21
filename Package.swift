// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "BridgeSupportParser",
    products: [
        .library(
            name: "BridgeSupportParser",
            targets: ["BridgeSupportParser"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", from: "1.0.0")
    ],
    targets: [
        .target(
                name: "BridgeSupportParser"
        ),
        .testTarget(
                name: "BridgeSupportParserTests",
                dependencies: [
                    "BridgeSupportParser",
                    "Difference"
                ],
                resources: [
                    .copy("Resources")
                ]
        ),
        .executableTarget(
            name: "BridgeSupportParserCommand",
            dependencies: [
                "BridgeSupportParser"
            ]
        )
    ]
)
