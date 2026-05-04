import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct StoryboardProcessorTests {
	@Test
	func composesCollectorAndRenderer() throws {
		let output = try withDependencies {
			$0[collectResourcesOf: .type(PackageResources.Storyboard.self)] = .init { path in
				expectNoDifference("/fixtures", path)
				return [.init(name: "Main")]
			}
			$0[renderResourcesOf: .type(PackageResources.Storyboard.Source.self)] = .init { resources in
				expectNoDifference([.init(name: "Main")], resources)
				return "storyboards"
			}
		} operation: {
			@Dependency(KeyPath.processResources(of: PackageResources.Storyboard.self))
			var processor
			return try processor("/fixtures")
		}

		expectNoDifference("storyboards", output)
	}
}
