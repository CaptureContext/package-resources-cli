import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies

@Suite
struct BracketedBlockSnippetTests {
	@Test
	func rendersMultilineSquareBlock() {
		let output = renderSnippet(.bracketedBlock(
			in: .square,
			contents: .join(",\n") {
				"first"
				"second"
			}
		))

		let expected = """
		[
			first,
			second
		]
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rendersInlineParenthesesBlock() {
		let output = renderSnippet(.bracketedBlock(
			in: .parentheses,
			isMultiline: false,
			contents: "value"
		))

		expectNoDifference("(value)", output)
	}

	@Test
	func rendersCustomCurlyBlock() {
		let output = renderSnippet(.bracketedBlock(
			in: .curly(openingSuffix: " [weak self] in"),
			contents: "value"
		))

		let expected = """
		{ [weak self] in
			value
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rendersBacktickBlock() {
		let output = renderSnippet(.bracketedBlock(
			in: .backticks(2),
			contents: "value"
		))

		let expected = """
		``
			value
		``
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsIndentationOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(indentor: " ", indentSize: 2)
		} operation: {
			renderSnippet(.bracketedBlock(
				in: .square,
				contents: "value"
			))
		}

		let expected = """
		[
		  value
		]
		"""

		expectNoDifference(expected, output)
	}
}
