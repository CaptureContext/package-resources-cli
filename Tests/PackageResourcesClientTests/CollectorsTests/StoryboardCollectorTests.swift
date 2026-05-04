import Testing
@testable import PackageResourcesClient

import CustomDump
import PackageResourcesCore

@Suite
struct StoryboardCollectorTests {
	@Test
	func collectsStoryboards() throws {
		let output = try PackageResources.Storyboard.collect(atPath: testFixturesDirectoryPath)

		let expected: [PackageResources.Storyboard.Source] = [
			.init(name: "Main")
		]

		expectNoDifference(expected, output)
	}
}
