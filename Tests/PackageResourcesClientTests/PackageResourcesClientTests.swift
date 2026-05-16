import Testing
@testable import PackageResourcesClient

import Dependencies
import PackageResourcesCore
import SnapshotTesting
import SnapshotTestingCustomDump
import Snippets
import SwiftSnippets

@Suite
struct PackageResourcesClientTests {
	@Test
	func stringOutput() async throws {
		@Dependency(\.packageResourcesClient)
		var sut

		let output = await sut.processResources(
			for: .all,
			atPath: testFixturesDirectoryPath
		)

		assertSnapshot(
			of: output,
			as: .swift,
			named: "default"
		)
	}

	@Test
	func publicTwoSpaceFlatCatalogOutput() async throws {
		let output = await withDependencies {
			$0.resourceFormatConfig = .standard(
				indentor: " ",
				indentSize: 2,
				accessLevel: .public,
				groupByCatalogName: false
			)
		} operation: {
			@Dependency(\.packageResourcesClient)
			var sut

			return await sut.processResources(
				for: .all,
				atPath: testFixturesDirectoryPath
			)
		}

		assertSnapshot(
			of: output,
			as: .swift,
			named: "default"
		)
	}

	@Test
	func resourceSpecificFormatOutput() async throws {
		var config = ResourceFormatConfig.standard()
		config.colors.common = .init(
			indentor: "  ",
			accessLevel: .public
		)
		config.images.common = .init(
			indentor: "    ",
			accessLevel: .package
		)
		config.fonts = .init(
			indentor: "  ",
			accessLevel: nil
		)
		config.xcStrings.catalog = .init(
			common: .init(
				indentor: "    ",
				accessLevel: .public
			),
			groupByCatalogName: false
		)
		config.xcStrings.splitByKeyPath = false

		let output = await withDependencies {
			$0.resourceFormatConfig = config
		} operation: {
			@Dependency(\.packageResourcesClient)
			var sut

			return await sut.processResources(
				for: .all,
				atPath: testFixturesDirectoryPath
			)
		}

		assertSnapshot(
			of: output,
			as: .swift,
			named: "default"
		)
	}

	@Test
	func fileOutput() async throws {
		@Dependency(\.packageResourcesClient)
		var sut

		@Dependency(\.generatedResourcesDisclaimerProvider)
		var disclaimer

		let snapshotDirName = String(describing: Self.self)
		let filename = "fileOutput.default.swift"

		try await sut.processResources(
			for: .all,
			atPath: testFixturesDirectoryPath,
			into: testSnapshotsDirectoryPath
				.appending("/" + snapshotDirName)
				.appending("/" + filename)
		)

		let disclaimerString = disclaimer(filename)

		let outputString = await sut.processResources(
			for: .all,
			atPath: testFixturesDirectoryPath
		)

		assertSnapshot(
			of: renderPackageResourceSnippet(
				Snippets.Join(String.const(.newlines(2))) {
					if let disclaimerString {
						disclaimerString
					}
					outputString
				}
				.skipEmpty()
			),
			as: .swift,
			named: "default"
		)
	}
}
