import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct ImageProcessorTests {
	@Test
	func composesCollectorAndRenderer() throws {
		let output = try withDependencies {
			$0[collectResourcesOf: .type(PackageResources.Image.self)] = .init { path in
				expectNoDifference("/fixtures", path)
				return [.init(name: "ImageExample")]
			}
			$0[renderResourcesOf: .type(PackageResources.Image.Source.self)] = .init { resources in
				expectNoDifference([.init(name: "ImageExample")], resources)
				return "images"
			}
		} operation: {
			@Dependency(KeyPath.processResources(of: PackageResources.Image.self))
			var processor
			return try processor("/fixtures")
		}

		expectNoDifference("images", output)
	}
}
