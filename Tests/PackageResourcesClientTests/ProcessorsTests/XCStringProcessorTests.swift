import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore
import XCStringsCatalog

@Suite
struct XCStringProcessorTests {
	@Test
	func composesCollectorAndRenderer() throws {
		let source = PackageResources.LocalizedString.Source(
			resource: .init(
				key: "welcome",
				comment: nil,
				arguments: [],
				sourceLocalization: "Welcome"
			),
			table: "Localizable"
		)

		let output = try withDependencies {
			$0[collectResourcesOf: .type(PackageResources.LocalizedString.self)] = .init { path in
				expectNoDifference("/fixtures", path)
				return [source]
			}
			$0[renderResourcesOf: .type(PackageResources.LocalizedString.Source.self)] = .init { resources in
				expectNoDifference([source], resources)
				return "xcstrings"
			}
		} operation: {
			@Dependency(KeyPath.processResources(of: PackageResources.LocalizedString.self))
			var processor
			return try processor("/fixtures")
		}

		expectNoDifference("xcstrings", output)
	}
}
