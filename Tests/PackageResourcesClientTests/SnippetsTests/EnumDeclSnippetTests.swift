import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies

@Suite
struct EnumDeclSnippetTests {
	@Test
	func rendersEnumWithConfiguredAccessLevel() {
		let output = renderSnippet(.enumDecl(
			name: "namespace",
			contents: "case value"
		))

		let expected = """
		internal enum namespace {
			case value
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsAccessLevelOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(accessLevel: .public)
		} operation: {
			renderSnippet(.enumDecl(
				name: "namespace",
				contents: "case value"
			))
		}

		let expected = """
		public enum namespace {
			case value
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsIndentationOverride() {
		let output = withDependencies {
			$0.formatClient = .standard(indentor: " ", indentSize: 2)
		} operation: {
			renderSnippet(.enumDecl(
				name: "namespace",
				contents: "case value"
			))
		}

		let expected = """
		internal enum namespace {
		  case value
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func omitsAccessLevelWhenProviderReturnsNil() {
		let output = withDependencies {
			$0.formatClient = .standard(accessLevel: nil)
		} operation: {
			renderSnippet(.enumDecl(
				name: "namespace",
				contents: "case value"
			))
		}

		let expected = """
		enum namespace {
			case value
		}
		"""

		expectNoDifference(expected, output)
	}
}
