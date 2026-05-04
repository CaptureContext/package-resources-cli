import Testing
@testable import PackageResourcesClient

import CustomDump

@Suite
struct JoinSnippetTests {
	@Test
	func joinsNonEmptySnippetsWithSeparator() {
		let output = renderSnippet(.join(", ") {
			"first"
			""
			"second"
		})

		expectNoDifference("first, second", output)
	}

	@Test
	func defaultsToNoSeparator() {
		let output = renderSnippet(.join {
			"first"
			"second"
		})

		expectNoDifference("firstsecond", output)
	}
}
