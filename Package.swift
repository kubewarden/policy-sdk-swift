// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kubewardenSdk",
    products: [
      .library(
        name: "kubewardenSdk",
        targets: ["kubewardenSdk"]),
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-log.git", from: "1.10.1"),
      .package(name: "GenericJSON", url: "https://github.com/zoul/generic-json-swift.git", from: "2.0.2"),
      .package(name: "wapc", url: "https://github.com/wapc/wapc-guest-swift.git", from: "0.0.2"),
    ],
    targets: [
        .target(
            name: "kubewardenSdk",
            dependencies: [
              .product(name: "Logging", package: "swift-log"),
              "GenericJSON",
              "wapc"
            ]),
        .testTarget(
            name: "kubewardenSdkTests",
            dependencies: ["kubewardenSdk"]
        )
    ]
)
