// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "NativeActivity", products: [
    .library(name: "NativeActivity", targets: ["NativeActivity"]),
], dependencies: [
    .package(url: "https://github.com/purpln/native-app-glue.git", branch: "main"),
], targets: [
    .target(name: "NativeActivity", dependencies: [
        .product(name: "NativeAppGlue", package: "native-app-glue"),
    ]),
])
