import Testing
@testable import PackageResourcesClient

import CustomDump
import PackageResourcesCore

@Suite
struct SCNSceneCollectorTests {
	@Test
	func collectsScenesAndCatalogName() throws {
		let output = try PackageResources.SCNScene.collect(atPath: testFixturesDirectoryPath)

		let expected: [PackageResources.SCNScene.Source] = [
			.init(name: "DefaultScene", catalog: "SCNCatalog")
		]

		expectNoDifference(expected, output)
	}
}
