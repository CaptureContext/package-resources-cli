// swift-tools-version: 6.1

import PackageDescription

let package = Package(
	name: "PackageResourcesPluginExample",
	platforms: [
		.macOS(.v15),
		.iOS(.v18),
	],
	products: [
		.library(
			name: "AppFeature",
			targets: ["AppFeature"]
		),
		.library(
			name: "AppUI",
			targets: ["AppUI"]
		),
		.library(
			name: "SomeFeature",
			targets: ["SomeFeature"]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/capturecontext/package-resources-cli.git",
			.upToNextMajor(from: "4.1.0")
		),
		.package(
			url: "https://github.com/capturecontext/swift-package-resources.git",
			.upToNextMajor(from: "5.0.1")
		),
		.package(
			url: "https://github.com/capturecontext/cocoa-aliases.git",
			.upToNextMajor(from: "3.5.2")
		),
	],
	targets: [
		.target(
			name: "AppFeature", // entry-point
			dependencies: [
				.target(name: "SomeFeature"),
			]
		),
		.target(
			name: "AppUI", // design-system
			dependencies: [
				.product(
					name: "PackageResources",
					package: "swift-package-resources"
				),
				.product(
					name: "CocoaAliases",
					package: "cocoa-aliases"
				),
			],
			resources: [
				.process("Resources"),
			],
			plugins: [
				.plugin(
					name: "package-resources-plugin",
					package: "package-resources-cli"
				),
			]
		),
		.target(
			name: "SomeFeature", // feature-module
			dependencies: [
				.target(name: "AppUI"),
			],
			resources: [
				.process("Resources"),
			],
			plugins: [
				.plugin(
					name: "package-resources-plugin",
					package: "package-resources-cli"
				),
			]
		),
	],
	swiftLanguageModes: [.v6]
)
