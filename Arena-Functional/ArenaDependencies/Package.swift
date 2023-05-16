// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArenaDependencies",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ArenaDependencies",
            targets: ["ArenaDependencies"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ArenaDependencies"),
        .testTarget(
            name: "ArenaDependenciesTests",
            dependencies: ["ArenaDependencies"]),
    ]
)

package.dependencies = [
//    .package(url: "https://github.com/rkayman/swift-prelude", branch: "main"),
//    .package(url: "https://github.com/pointfreeco/swift-overture", from: "0.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.10.0"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.4.0"),
    .package(url: "https://github.com/malcommac/swiftdate", from: "7.0.0"),
    .package(url: "https://github.com/rkayman/funswift", branch: "main")
]
package.targets = [
    .target(name: "ArenaDependencies",
        dependencies: [
            .product(name: "Tagged", package: "swift-tagged"),
            .product(name: "TaggedMoney", package: "swift-tagged"),
            .product(name: "TaggedTime", package: "swift-tagged"),
            .product(name: "NonEmpty", package: "swift-nonempty"),
            .product(name: "SwiftDate", package: "SwiftDate"),
            .product(name: "Funswift", package: "Funswift")
        ]
    )
]
package.platforms = [
    .macOS("10.15"),
    .iOS("13.0"),
    .tvOS("13.0"),
    .watchOS("6.0")
]
