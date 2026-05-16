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
			.init(name: "ImageExample"),
			.init(name: "NestedImage", path: ["NestedFolder"])
		]

		expectNoDifference(expected, output)
	}
}
