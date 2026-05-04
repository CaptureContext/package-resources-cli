import Testing
@testable import PackageResourcesClient

import CustomDump

@Suite
struct CommentSnippetTests {
	@Test
	func rendersBasicCommentsAcrossMultipleLines() {
		let output = renderSnippet(.comment("one\n\ntwo"))

		let expected = """
		// one
		//
		// two
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rendersDocCommentsAcrossMultipleLines() {
		let output = renderSnippet(.docComment("one\n\ntwo"))

		let expected = """
		/// one
		///
		/// two
		"""

		expectNoDifference(expected, output)
	}
}
