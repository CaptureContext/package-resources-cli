import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct ColorRendererTests {
	@Test
	func rendersColorAccessors() throws {
		let output = try PackageResources.Color.Source.render([
			.init(name: "AccentColor")
		])

		let expected = """
		extension _ColorResource {
			internal static var accentColor: Self {
				.init(
					name: "AccentColor",
					bundle: .module
				)
			}
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsFormattingOverrides() throws {
		let output = try withDependencies {
			$0.formatClient = .standard(indentor: " ", indentSize: 2, accessLevel: .public)
		} operation: {
			try PackageResources.Color.Source.render([
				.init(name: "AccentColor")
			])
		}

		let expected = """
		extension _ColorResource {
		  public static var accentColor: Self {
		    .init(
		      name: "AccentColor",
		      bundle: .module
		    )
		  }
		}
		"""

		expectNoDifference(expected, output)
	}
}
