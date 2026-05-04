import Testing
@testable import PackageResourcesClient

import CustomDump

@Suite
struct RenderSnippetTests {
	@Test
	func wrapsNonEmptySnippet() {
		expectNoDifference("[value]", renderSnippet("value", prefix: "[", suffix: "]"))
	}

	@Test
	func rendersEmptySnippetAsEmptyString() {
		expectNoDifference("", renderSnippet("", prefix: "[", suffix: "]"))
	}

	@Test
	func rendersNilSnippetAsEmptyString() {
		expectNoDifference("", renderSnippet(String?.none, prefix: "[", suffix: "]"))
	}
}
