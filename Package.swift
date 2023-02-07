// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MagicSDK",
    platforms: [
       .iOS(.v10),
       .macOS(.v10_12)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MagicSDK",
            targets: ["MagicSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/magiclabs/Web3.swift.git", from:"1.1.0"),
        .package(url: "https://github.com/mxcl/PromiseKit.git", from:"6.16.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MagicSDK",
            dependencies: [
                .product(name: "MagicSDK_Web3", package: "Web3.swift"),
                .product(name: "Web3PromiseKit", package: "Web3.swift"),
                .product(name: "PromiseKit", package: "PromiseKit"),
                .product(name: "Web3ContractABI", package: "Web3.swift")
            ]),
        .testTarget(
            name: "MagicSDKTests",
            dependencies: [
                .target(name: "MagicSDK")
            ]),
    ]
)
