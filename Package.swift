// swift-tools-version: 5.9
//
// NotchPrompter — Swift Package Manager manifest.
//
// - Swift language mode 5 (tools 5.9) so the app code does not require
//   Swift 6 constructs such as @retroactive.
// - The NotchPrompter executable target is macOS-only and is excluded on
//   Linux (via #if os(macOS)) so that `swift test` builds only the portable
//   PrompterCore library and its tests.
//
import PackageDescription

#if os(macOS)
let appProducts: [Product] = [
    .executable(name: "NotchPrompter", targets: ["NotchPrompter"]),
]

let appTargets: [Target] = [
    .executableTarget(
        name: "NotchPrompter",
        dependencies: ["PrompterCore"],
        path: "notch-prompter",
        exclude: ["Assets.xcassets"]
    ),
]
#else
let appProducts: [Product] = []
let appTargets: [Target] = []
#endif

let package = Package(
    name: "NotchPrompter",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(name: "PrompterCore", targets: ["PrompterCore"]),
    ] + appProducts,
    targets: [
        .target(
            name: "PrompterCore",
            path: "Sources/PrompterCore"
        ),
        .testTarget(
            name: "PrompterCoreTests",
            dependencies: ["PrompterCore"],
            path: "Tests/PrompterCoreTests"
        ),
    ] + appTargets,
    swiftLanguageVersions: [.v5]
)
