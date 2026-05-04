import Testing
@testable import PackageResourcesClient

import CustomDump
import PackageResourcesCore

@Suite
struct NibCollectorTests {
	@Test
	func collectsNibs() throws {
		let output = try PackageResources.Nib.collect(atPath: testFixturesDirectoryPath)

		let expected: [PackageResources.Nib.Source] = [
			.init(name: "Main")
		]

		expectNoDifference(expected, output)
	}
}
