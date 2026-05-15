import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct NibRendererTests {
	@Test
	func rendersNibAccessors() throws {
		let output = try PackageResources.Nib.Source.render([
			.init(name: "Main")
		])

		let expected = """
		extension _NibResource {
			internal static var main: Self {
				.init(
					name: "Main",
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
			try PackageResources.Nib.Source.render([
				.init(name: "Main")
			])
		}

		let expected = """
		extension _NibResource {
		  public static var main: Self {
		    .init(
		      name: "Main",
		      bundle: .module
		    )
		  }
		}
		"""

		expectNoDifference(expected, output)
	}
}
