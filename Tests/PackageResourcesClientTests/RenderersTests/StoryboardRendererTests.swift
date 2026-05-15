import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct StoryboardRendererTests {
	@Test
	func rendersStoryboardAccessors() throws {
		let output = try PackageResources.Storyboard.Source.render([
			.init(name: "Main")
		])

		let expected = """
		extension _StoryboardResource {
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
			try PackageResources.Storyboard.Source.render([
				.init(name: "Main")
			])
		}

		let expected = """
		extension _StoryboardResource {
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
