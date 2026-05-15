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
	func fileOutput() async throws {
		@Dependency(\.packageResourcesClient)
		var sut

		@Dependency(\.formatClient.disclaimerProvider)
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
