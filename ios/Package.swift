// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AnagramTrainer",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AnagramTrainer",
            targets: ["AnagramTrainer"])
    ],
    targets: [
        .target(
            name: "AnagramTrainer",
            path: "AnagramTrainer",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
