import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct ColorProcessorTests {
	@Test
	func composesCollectorAndRenderer() throws {
		let output = try withDependencies {
			$0[collectResourcesOf: .type(PackageResources.Color.self)] = .init { path in
				expectNoDifference("/fixtures", path)
				return [.init(name: "AccentColor")]
			}
			$0[renderResourcesOf: .type(PackageResources.Color.Source.self)] = .init { resources in
				expectNoDifference([.init(name: "AccentColor")], resources)
				return "colors"
			}
		} operation: {
			@Dependency(KeyPath.processResources(of: PackageResources.Color.self))
			var processor
			return try processor("/fixtures")
		}

		expectNoDifference("colors", output)
	}
}
