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
			internal enum scncatalog {
				internal static var defaultScene: _SCNSceneResource {
					.init(
						name: "DefaultScene",
						catalog: "SCNCatalog",
						bundle: .module
					)
				}
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
		  public enum scncatalog {
		    public static var defaultScene: _SCNSceneResource {
		      .init(
		        name: "DefaultScene",
		        catalog: "SCNCatalog",
		        bundle: .module
		      )
		    }
		  }
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func groupsScenesBySCNAssetFolders() throws {
		let output = try PackageResources.SCNScene.Source.render([
			.init(
				name: "Intro.Scene",
				path: ["Stages", "Primary"],
				catalog: "SCNCatalog"
			)
		])

		let expected = """
		extension _SCNSceneResource {
			internal enum scncatalog {
				internal enum stages {
					internal enum primary {
						internal enum intro {
							internal static var scene: _SCNSceneResource {
								.init(
									name: "Intro.Scene",
									catalog: "SCNCatalog",
									bundle: .module
								)
							}
						}
					}
				}
			}
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rejectsConflictingAccessorAndNestedKeyPaths() throws {
		let resources = [
			PackageResources.SCNScene.Source(name: "some.key"),
			.init(name: "some.key.label")
		]

		for resources in [resources, resources.reversed()] {
			do {
				_ = try PackageResources.SCNScene.Source.render(Array(resources))
				Issue.record("Expected conflicting scene resource namespaces to throw.")
			} catch let error as SCNSceneResourceValidationError {
				expectNoDifference(
					.conflictingNamespaces([
						.init(accessorName: "some.key", namespaceName: "some.key.label")
					]),
					error
				)
			} catch {
				Issue.record("Expected SCNSceneResourceValidationError, got \(error).")
			}
		}
	}
}
