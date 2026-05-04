import Testing
@testable import PackageResourcesClient

import CustomDump
import PackageResourcesCore

@Suite
struct XCStringCollectorTests {
	@Test
	func collectsXCStringsAndTableName() throws {
		let output = try PackageResources.LocalizedString.collect(atPath: testFixturesDirectoryPath)

		expectNoDifference(1, output.count)
		expectNoDifference("Localizable", output.first?.table)
		expectNoDifference("unformatted.test_key.withValues", output.first?.resource.key)
		expectNoDifference("Some comment", output.first?.resource.comment)
		expectNoDifference(
			"Default localization %1$(string)@ %2$(int)lld and unnamed %3$lf",
			output.first?.resource.sourceLocalization
		)
		expectNoDifference(["string", "int", nil], output.first?.resource.arguments.map(\.label))
		expectNoDifference(["arg1", "arg2", "arg3"], output.first?.resource.arguments.map(\.name))
		expectNoDifference([.object, .int, .double], output.first?.resource.arguments.map(\.placeholderType))
	}
}
