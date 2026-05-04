import Testing
@testable import PackageResourcesClient

import Dependencies
import PackageResourcesCore
import SnapshotTesting
import SnapshotTestingCustomDump

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
			of: renderSnippet(.join("\n\n") {
				renderSnippet(disclaimerString)
				outputString
			}),
			as: .swift,
			named: "default"
		)
	}
}
