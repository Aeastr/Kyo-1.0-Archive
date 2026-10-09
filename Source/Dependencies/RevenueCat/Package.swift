// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

// FIX: Archive only the two runtime products used by Kyo; omit upstream tests and their dependencies.
// See ARCHIVE-PROVENANCE.md and UPSTREAM-Package.swift.txt.

import PackageDescription
import class Foundation.ProcessInfo

// Only add DocC Plugin when building docs, so that clients of this library won't
// unnecessarily also get the DocC Plugin
let environmentVariables = ProcessInfo.processInfo.environment
let shouldIncludeDocCPlugin = environmentVariables["INCLUDE_DOCC_PLUGIN"] == "true"

// See https://github.com/RevenueCat/purchases-ios/pull/2989
// #if os(visionOS) can't really be used in Xcode 13, so we use this instead.
let visionOSSetting: SwiftSetting = .define("VISION_OS", .when(platforms: [.visionOS]))

let package = Package(
    name: "RevenueCat",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v10_13),
        .watchOS("6.2"),
        .tvOS(.v11),
        .iOS(.v11),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "RevenueCat",
                 targets: ["RevenueCat"]),
        .library(name: "RevenueCatUI",
                 targets: ["RevenueCatUI"])
    ],
    targets: [
        .target(name: "RevenueCat",
                path: "Sources",
                exclude: ["Info.plist", "LocalReceiptParsing/ReceiptParser-only-files"],
                resources: [
                    .copy("../Sources/PrivacyInfo.xcprivacy")
                ],
                swiftSettings: [visionOSSetting]),
        // RevenueCatUI
        .target(name: "RevenueCatUI",
                dependencies: ["RevenueCat"],
                path: "RevenueCatUI",
                resources: [
                    // Note: these have to match the values in RevenueCatUI.podspec
                    .copy("Resources/background.jpg"),
                    .process("Resources/icons.xcassets")
                ])
    ]
)
