// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "swift-distributed-tracing-baggage-core",
    products: [
        .library(
            name: "CoreBaggage",
            targets: [
                "CoreBaggage",
            ]
        ),
    ],
    dependencies: [
        // no dependencies
    ],
    targets: [
        .target(
            name: "CoreBaggage",
            dependencies: []
        ),

        // ==== --------------------------------------------------------------------------------------------------------
        // MARK: Tests

        .testTarget(
            name: "CoreBaggageTests",
            dependencies: [
                "CoreBaggage",
            ]
        ),
    ]
)
