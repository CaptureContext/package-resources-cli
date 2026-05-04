import Testing
@testable import PackageResourcesClient

import CustomDump
import PackageResourcesCore

@Suite
struct FontCollectorTests {
	@Test
	func collectsFonts() throws {
		let output = try PackageResources.Font.collect(atPath: testFixturesDirectoryPath)
			.sorted { $0.name < $1.name }

		let expected: [PackageResources.Font.Source] = [
			.init(name: "Arimo-Bold"),
			.init(name: "Montserrat-Black")
		]

		expectNoDifference(expected, output)
	}
}
