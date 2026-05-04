import Testing
@testable import PackageResourcesClient

import CustomDump

@Suite
struct MethodCallSnippetTests {
	@Test
	func rendersSingleArgumentCallInlineByDefault() {
		let output = renderSnippet(.methodCall(
			name: ".init",
			args: [
				.callArgument(name: "name", value: "\"Color\"")
			]
		))

		expectNoDifference(".init(name: \"Color\")", output)
	}

	@Test
	func rendersMultipleArgumentCallAcrossLinesByDefault() {
		let output = renderSnippet(.methodCall(
			name: ".init",
			args: [
				.callArgument(name: "name", value: "\"Color\""),
				.callArgument(name: "bundle", value: ".module")
			]
		))

		let expected = """
		.init(
			name: "Color",
			bundle: .module
		)
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func allowsExplicitSingleLineMultipleArgumentCall() {
		let output = renderSnippet(.methodCall(
			name: ".init",
			isMultiline: false,
			args: [
				.callArgument(name: "name", value: "\"Color\""),
				.callArgument(name: "bundle", value: ".module")
			]
		))

		expectNoDifference(".init(name: \"Color\", bundle: .module)", output)
	}

	@Test
	func callArgumentsCanRenderSingleLine() {
		let output = renderSnippet(.callArguments(isMultiline: false) {
			Snippets.MethodCall.Argument(name: "name", value: "\"Color\"")
			Snippets.MethodCall.Argument(name: "bundle", value: ".module")
		})

		expectNoDifference("name: \"Color\", bundle: .module", output)
	}
}
