// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "package-resources-cli",
	platforms: [
		.iOS(.v13),
		.macOS(.v10_15),
		.tvOS(.v13),
		.watchOS(.v6),
		.macCatalyst(.v13),
	],
	products: [
		.plugin(
			name: "package-resources-plugin",
			targets: ["package-resources-plugin"]
		),
		.plugin(
			name: "package-resources-cli-plugin",
			targets: ["package-resources-cli-plugin"]
		),
		.library(
			name: "PackageResourcesClient",
			targets: ["PackageResourcesClient"]
		),
		.library(
			name: "_ExportedPackageResources",
			targets: ["_ExportedPackageResources"]
		),
		.library(
			name: "_ExportedPackageResourcesCore",
			targets: ["_ExportedPackageResourcesCore"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/apple/swift-argument-parser.git",
			.upToNextMajor(from: "1.7.0")
		),
		.package(
			url: "https://github.com/jpsim/yams.git",
			.upToNextMajor(from: "6.2.0")
		),
		.package(
			url: "https://github.com/capturecontext/swift-casification.git",
			.upToNextMinor(from: "0.5.0")
		),
		.package(
			url: "https://github.com/capturecontext/swift-package-resources.git",
			.upToNextMinor(from: "4.0.0")
		),
	],
	targets: [
		.plugin(
			name: "package-resources-plugin",
			capability: .buildTool(),
			dependencies: [
				.target(name: "package-resources-cli")
			]
		),
		.plugin(
			name: "package-resources-cli-plugin",
			capability: .command(
				intent: .custom(
					verb: "resources",
					description: "manages package-resources-cli configuration"
				),
				permissions: [
					.writeToPackageDirectory(
						reason: """
						Write permission is needed to create and modify \
						config file for package-resources-cli
						"""
					)
				]
			),
			dependencies: [
				.target(name: "package-resources-cli")
			]
		),
		.executableTarget(
			name: "package-resources-cli",
			dependencies: [
				.target(name: "PackageResourcesClient"),
				.product(
					name: "ArgumentParser",
					package: "swift-argument-parser"
				),
				.product(
					name: "Yams",
					package: "yams"
				),
			],
			path: "Sources/package-resources-cli"
		),
		.target(
			name: "PackageResourcesClient",
			dependencies: [
				.target(name: "PackageResourcesFS"),
				.product(
					name: "PackageResourcesCore",
					package: "swift-package-resources"
				),
				.product(
					name: "Casification",
					package: "swift-casification"
				),
			],
			path: "Sources/package-resources-client"
		),
		.target(
			name: "PackageResourcesFS",
			path: "Sources/package-resources-fs"
		),
		.target(
			name: "_ExportedPackageResources",
			dependencies: [
				.product(
					name: "PackageResources",
					package: "swift-package-resources"
				),
			],
			path: "Sources/Aliases/package-resources"
		),
		.target(
			name: "_ExportedPackageResourcesCore",
			dependencies: [
				.product(
					name: "PackageResourcesCore",
					package: "swift-package-resources"
				),
			],
			path: "Sources/Aliases/package-resources-core"
		),
		.testTarget(
			name: "PackageResourcesClientTests",
			dependencies: [
				.target(name: "PackageResourcesClient")
			],
			exclude: [
				"_Resources"
			]
		),
	],
	swiftLanguageModes: [.v6]
)
