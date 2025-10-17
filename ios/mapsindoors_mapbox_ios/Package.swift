// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let mapsindoorsVersion = Version("4.15.2")

let package = Package(
    name: "mapsindoors_mapbox_ios",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "mapsindoors-mapbox-ios",
            targets: ["mapsindoors_mapbox_ios"])
    ],
    dependencies: [
        .package(url: "https://github.com/MapsPeople/mapsindoors-codable-ios.git", exact: mapsindoorsVersion),
        .package(url: "https://github.com/MapsPeople/mapsindoors-mapbox-ios.git", exact: mapsindoorsVersion),
    ],
    targets: [
        .target(
            name: "mapsindoors_mapbox_ios",
            dependencies: [
                .product(name: "MapsIndoorsCodable", package: "mapsindoors-codable-ios"),
                .product(name: "MapsIndoorsMapbox", package: "mapsindoors-mapbox-ios"),
            ]
        )
    ]
)
