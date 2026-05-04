import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct FontProcessorTests {
	@Test
	func composesCollectorAndRenderer() throws {
		let output = try withDependencies {
			$0[collectResourcesOf: .type(PackageResources.Font.self)] = .init { path in
				expectNoDifference("/fixtures", path)
				return [.init(name: "Arimo-Bold")]
			}
			$0[renderResourcesOf: .type(PackageResources.Font.Source.self)] = .init { resources in
				expectNoDifference([.init(name: "Arimo-Bold")], resources)
				return "fonts"
			}
		} operation: {
			@Dependency(KeyPath.processResources(of: PackageResources.Font.self))
			var processor
			return try processor("/fixtures")
		}

		expectNoDifference("fonts", output)
	}
}
