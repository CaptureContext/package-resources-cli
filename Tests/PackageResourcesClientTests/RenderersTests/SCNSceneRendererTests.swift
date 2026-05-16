import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct SCNSceneRendererTests {
	@Test
	func rendersSceneAccessorsWithAndWithoutCatalog() throws {
		let output = try PackageResources.SCNScene.Source.render([
			.init(name: "DefaultScene", catalog: "SCNCatalog"),
			.init(name: "LooseScene", catalog: nil)
		])

		let expected = """
		extension _SCNSceneResource {
			internal static var defaultScene: Self {
				.init(
					name: "DefaultScene",
					catalog: "SCNCatalog",
					bundle: .module
				)
			}
		
			internal static var looseScene: Self {
				.init(
					name: "LooseScene",
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
			$0.resourceFormatConfig = .standard(indentor: " ", indentSize: 2, accessLevel: .public)
		} operation: {
			try PackageResources.SCNScene.Source.render([
				.init(name: "DefaultScene", catalog: "SCNCatalog")
			])
		}

		let expected = """
		extension _SCNSceneResource {
		  public static var defaultScene: Self {
		    .init(
		      name: "DefaultScene",
		      catalog: "SCNCatalog",
		      bundle: .module
		    )
		  }
		}
		"""

		expectNoDifference(expected, output)
	}
}
