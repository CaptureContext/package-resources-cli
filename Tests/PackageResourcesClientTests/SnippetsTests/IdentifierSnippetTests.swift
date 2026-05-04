import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies

@Suite
struct IdentifierSnippetTests {
	@Test
	func rendersCamelCaseIdentifierByDefault() {
		expectNoDifference("someValueID", renderSnippet(.identifier("some-value_ID")))
	}

	@Test
	func respectsCamelCaseModeOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(camelCaseMode: .pascal)
		} operation: {
			renderSnippet(.identifier("some-value_ID"))
		}

		expectNoDifference("SomeValueID", output)
	}
}
