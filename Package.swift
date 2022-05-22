// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataStreams",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DataStreams",
            targets: ["DataStreams"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/aetherealtech/SwiftCoreExtensions.git", branch: "master"),
        .package(url: "https://github.com/aetherealtech/SwiftEventStreams.git", branch: "master"),
        .package(url: "https://github.com/aetherealtech/SwiftScheduling.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DataStreams",
            dependencies: [
                .product(name: "CoreExtensions", package: "SwiftCoreExtensions"),
                .product(name: "EventStreams", package: "SwiftEventStreams"),
                .product(name: "Scheduling", package: "SwiftScheduling"),
            ]),
        .testTarget(
            name: "DataStreamsTests",
            dependencies: ["DataStreams"]),
    ]
)
