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
			from: "3.0.0"
		),
		.package(
			url: "https://github.com/capturecontext/swift-package-resources.git",
			from: "4.0.0"
		),
		.package(
			url: "https://github.com/capturecontext/cocoa-aliases.git",
			from: "3.3.0"
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

extension Array<Package.Dependency> {
	/// Use this to depend on local cli
	func useLocalPackageResourcesCLI() -> Self {
		_override("package-resources-cli")
	}

	/// CaptureContext internal alias for local development
	func useLocalPackageResources() -> Self {
		_override("swift-package-resources")
	}

	/// CaptureContext internal alias for local development
	func useLocalCasification() -> Self {
		_override("swift-casification")
	}

	/// CaptureContext internal alias for local development
	func cctx_local_development() -> Self {
		self.useLocalCasification()
			.useLocalPackageResources()
			.useLocalPackageResourcesCLI()
	}

	private func _override(_ name: String) -> Self {
		[.package(path: "../../\(name)")] + self.filter {
			switch $0.kind {
			case let .fileSystem(packageName, path):
				return name != packageName && !path.contains(name)
			case let .sourceControl(packageName, location, _):
				return name != packageName && !location.contains(name)
			default:
				return true
			}
		}
	}
}
