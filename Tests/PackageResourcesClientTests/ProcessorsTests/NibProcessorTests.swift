import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct NibProcessorTests {
	@Test
	func composesCollectorAndRenderer() throws {
		let output = try withDependencies {
			$0[collectResourcesOf: .type(PackageResources.Nib.self)] = .init { path in
				expectNoDifference("/fixtures", path)
				return [.init(name: "Main")]
			}
			$0[renderResourcesOf: .type(PackageResources.Nib.Source.self)] = .init { resources in
				expectNoDifference([.init(name: "Main")], resources)
				return "nibs"
			}
		} operation: {
			@Dependency(KeyPath.processResources(of: PackageResources.Nib.self))
			var processor
			return try processor("/fixtures")
		}

		expectNoDifference("nibs", output)
	}
}
