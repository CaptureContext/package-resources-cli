import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies

@Suite
struct PropertyDeclSnippetTests {
	@Test
	func rendersStaticPropertyByDefault() {
		let output = renderSnippet(.propertyDecl(
			identifier: "title",
			returnType: "String",
			body: "\"Title\""
		))

		let expected = """
		internal static var title: String {
			"Title"
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rendersInstancePropertyWhenRequested() {
		let output = renderSnippet(.propertyDecl(
			isStatic: false,
			identifier: "title",
			returnType: "String",
			body: "\"Title\""
		))

		let expected = """
		internal var title: String {
			"Title"
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsAccessLevelOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(accessLevel: .public)
		} operation: {
			renderSnippet(.propertyDecl(
				identifier: "title",
				returnType: "String",
				body: "\"Title\""
			))
		}

		let expected = """
		public static var title: String {
			"Title"
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsIndentationOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(indentor: " ", indentSize: 2)
		} operation: {
			renderSnippet(.propertyDecl(
				identifier: "title",
				returnType: "String",
				body: "\"Title\""
			))
		}

		let expected = """
		internal static var title: String {
		  "Title"
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func omitsAccessLevelWhenProviderReturnsNil() {
		let output = withDependencies {
			$0.formatClient = .standard(accessLevel: nil)
		} operation: {
			renderSnippet(.propertyDecl(
				isStatic: false,
				identifier: "value",
				returnType: "Int",
				body: "1"
			))
		}

		let expected = """
		var value: Int {
			1
		}
		"""

		expectNoDifference(expected, output)
	}
}
