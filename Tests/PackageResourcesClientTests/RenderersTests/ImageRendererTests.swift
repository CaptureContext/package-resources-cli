import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct ImageRendererTests {
	@Test
	func rendersImageAccessors() throws {
		let output = try PackageResources.Image.Source.render([
			.init(name: "image-example")
		])

		let expected = """
		extension PackageResources.Image {
			internal static var imageExample: Self {
				.init(
					name: "image-example",
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
			try PackageResources.Image.Source.render([
				.init(name: "image-example")
			])
		}

		let expected = """
		extension PackageResources.Image {
		  public static var imageExample: Self {
		    .init(
		      name: "image-example",
		      bundle: .module
		    )
		  }
		}
		"""

		expectNoDifference(expected, output)
	}
}
