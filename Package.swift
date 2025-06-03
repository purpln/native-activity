// swift-tools-version: 5.5

import PackageDescription

let package = Package(name: "NativeActivity", products: [
    .library(name: "NativeActivity", targets: ["NativeActivity"]),
], dependencies: [
    .package(url: "https://github.com/purpln/android-entry.git", branch: "main"),
    .package(url: "https://github.com/purpln/android-log.git", branch: "main"),
    .package(url: "https://github.com/purpln/native-app-glue.git", branch: "main"),
], targets: [
    .target(name: "NativeActivity", dependencies: [
        .product(name: "AndroidEntry", package: "android-entry"),
        .product(name: "AndroidLog", package: "android-log"),
        .product(name: "NativeAppGlue", package: "native-app-glue"),
    ]),
])
