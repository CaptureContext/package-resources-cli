import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies

@Suite
struct ExtensionDeclSnippetTests {
	@Test
	func rendersExtensionWithWhereClause() {
		let output = renderSnippet(.extensionDecl(
			name: "Array",
			whereClause: "where Element == String",
			contents: "static var values: Self { [] }"
		))

		let expected = """
		extension Array where Element == String {
			static var values: Self { [] }
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rendersExtensionAccessModifier() {
		let output = renderSnippet(.extensionDecl(
			accessModifier: .public,
			name: "Type",
			contents: "static var value: Self { .init() }"
		))

		let expected = """
		public extension Type {
			static var value: Self { .init() }
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsIndentationOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(indentor: " ", indentSize: 2)
		} operation: {
			renderSnippet(.extensionDecl(
				name: "Type",
				contents: "static var value: Self { .init() }"
			))
		}

		let expected = """
		extension Type {
		  static var value: Self { .init() }
		}
		"""

		expectNoDifference(expected, output)
	}
}
