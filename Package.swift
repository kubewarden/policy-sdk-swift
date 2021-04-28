// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "kubewardenSdk",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "kubewardenSdk",
            targets: ["kubewardenSdk"]),
    ],
    dependencies: [
        .package(name: "GenericJSON", url: "https://github.com/zoul/generic-json-swift.git", from: "2.0.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "kubewardenSdk",
            dependencies: ["GenericJSON"]),
        .testTarget(
            name: "kubewardenSdkTests",
            dependencies: ["kubewardenSdk"]),
    ]
)
