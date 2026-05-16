import Testing
@testable import PackageResourcesClient

import CustomDump
import PackageResourcesCore

@Suite
struct ImageCollectorTests {
	@Test
	func collectsImageSets() throws {
		let output = try PackageResources.Image.collect(atPath: testFixturesDirectoryPath)

		let expected: [PackageResources.Image.Source] = [
			.init(name: "ImageExample", catalog: "Media"),
			.init(name: "NestedImage", path: ["NestedFolder"], catalog: "Media")
		]

		expectNoDifference(expected, output)
	}
}
