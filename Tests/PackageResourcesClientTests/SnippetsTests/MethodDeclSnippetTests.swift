import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies

@Suite
struct MethodDeclSnippetTests {
	@Test
	func rendersStaticMethodByDefault() {
		let output = renderSnippet(.methodDecl(
			identifier: "load",
			arguments: [
				.init(label: "from", name: "path", type: "String"),
				.init(label: nil, name: "count", type: "Int")
			],
			effects: "throws",
			returnType: "String",
			body: "try path"
		))

		let expected = """
		internal static func load(
			from path: String,
			count: Int
		) throws -> String {
			try path
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rendersInstanceMethodWhenRequested() {
		let output = renderSnippet(.methodDecl(
			isStatic: false,
			identifier: "load",
			returnType: "String",
			body: "\"value\""
		))

		let expected = """
		internal func load() -> String {
			"value"
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func argumentOmitsDuplicateExternalLabel() {
		let output = Snippets.MethodDecl.Argument(
			label: "value",
			name: "value",
			type: "String"
		).render()

		expectNoDifference("value: String", output)
	}

	@Test
	func respectsAccessLevelOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(accessLevel: .public)
		} operation: {
			renderSnippet(.methodDecl(
				isStatic: false,
				identifier: "load",
				arguments: [
					.init(label: "from", name: "path", type: "String")
				],
				returnType: "String",
				body: "path"
			))
		}

		let expected = """
		public func load(from path: String) -> String {
			path
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsIndentationOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(indentor: " ", indentSize: 2)
		} operation: {
			renderSnippet(.methodDecl(
				isStatic: false,
				identifier: "load",
				arguments: [
					.init(label: "from", name: "path", type: "String")
				],
				returnType: "String",
				body: "path"
			))
		}

		let expected = """
		internal func load(from path: String) -> String {
		  path
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func omitsAccessLevelWhenProviderReturnsNil() {
		let output = withDependencies {
			$0.formatClient = .standard(accessLevel: nil)
		} operation: {
			renderSnippet(.methodDecl(
				identifier: "load",
				returnType: "String",
				body: "\"value\""
			))
		}

		let expected = """
		static func load() -> String {
			"value"
		}
		"""

		expectNoDifference(expected, output)
	}
}
