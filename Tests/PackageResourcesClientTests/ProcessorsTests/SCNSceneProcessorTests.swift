import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct SCNSceneProcessorTests {
	@Test
	func composesCollectorAndRenderer() throws {
		let output = try withDependencies {
			$0[collectResourcesOf: .type(PackageResources.SCNScene.self)] = .init { path in
				expectNoDifference("/fixtures", path)
				return [.init(name: "DefaultScene", catalog: "SCNCatalog")]
			}
			$0[renderResourcesOf: .type(PackageResources.SCNScene.Source.self)] = .init { resources in
				expectNoDifference([.init(name: "DefaultScene", catalog: "SCNCatalog")], resources)
				return "scenes"
			}
		} operation: {
			@Dependency(KeyPath.processResources(of: PackageResources.SCNScene.self))
			var processor
			return try processor("/fixtures")
		}

		expectNoDifference("scenes", output)
	}
}
