import Testing
@testable import PackageResourcesClient

import CustomDump
import PackageResourcesCore

@Suite
struct ColorCollectorTests {
	@Test
	func collectsColorSets() throws {
		let output = try PackageResources.Color.collect(atPath: testFixturesDirectoryPath)

		let expected: [PackageResources.Color.Source] = [
			.init(name: "ColorExample")
		]

		expectNoDifference(expected, output)
	}
}
