import Testing
@testable import PackageResourcesClient

import CustomDump

@Suite
struct StringSnippetTests {
	@Test
	func rendersItself() {
		expectNoDifference("value", renderSnippet("value"))
	}
}
