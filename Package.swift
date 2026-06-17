// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "TFYSwiftEasyBlueTooth",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TFYSwiftEasyBlueToothKit",
            targets: ["TFYSwiftEasyBlueToothKit"]
        )
    ],
    targets: [
        .target(
            name: "TFYSwiftEasyBlueToothKit",
            path: "TFYSwiftEasyBlueTooth/TFYSwiftEasyBlueToothKit"
        ),
        .testTarget(
            name: "TFYSwiftEasyBlueToothKitTests",
            dependencies: ["TFYSwiftEasyBlueToothKit"],
            path: "TFYSwiftEasyBlueToothKitTests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
