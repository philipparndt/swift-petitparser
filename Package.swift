// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "swift-petitparser",
    products: [
        .library(name: "swift-petitparser", targets: ["swift-petitparser"]),
        ],
    dependencies: [],
    targets: [
        .target(
            name: "swift-petitparser",
            dependencies: [],
            path: "src/swift-petitparser/"
        ),
        .testTarget(
            name: "swift-petitparser-tests", 
            dependencies: ["swift-petitparser"],
            path: "src/Tests/"
        ),
    ]
)