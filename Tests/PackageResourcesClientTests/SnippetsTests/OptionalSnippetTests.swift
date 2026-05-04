import Testing
@testable import PackageResourcesClient

import CustomDump

@Suite
struct OptionalSnippetTests {
	@Test
	func rendersWrappedSnippet() {
		let value: String? = "value"

		expectNoDifference("value", renderSnippet(value))
	}

	@Test
	func rendersNilAsEmptyString() {
		let empty: String? = nil

		expectNoDifference("", renderSnippet(empty))
	}
}
