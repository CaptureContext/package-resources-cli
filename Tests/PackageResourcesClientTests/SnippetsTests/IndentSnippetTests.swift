import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies

@Suite
struct IndentSnippetTests {
	@Test
	func indentsEachLineWithDefaultTabs() {
		let output = renderSnippet("line1\nline2".indented(by: 2))

		let expected = """
				line1
				line2
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsIndentationOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(indentor: " ", indentSize: 2)
		} operation: {
			renderSnippet("line1\nline2".indented(by: 2))
		}

		let expected = """
		    line1
		    line2
		"""

		expectNoDifference(expected, output)
	}
}
