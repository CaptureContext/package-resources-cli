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
		extension _ImageResource {
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
			$0.resourceFormatConfig = .standard(indentor: " ", indentSize: 2, accessLevel: .public)
		} operation: {
			try PackageResources.Image.Source.render([
				.init(name: "image-example")
			])
		}

		let expected = """
		extension _ImageResource {
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

	@Test
	func groupsImagesByXCAssetFolders() throws {
		let output = try PackageResources.Image.Source.render([
			.init(
				name: "settings-icon",
				path: ["Toolbar", "Primary"]
			)
		])

		let expected = """
		extension _ImageResource {
			internal enum toolbar {
				internal enum primary {
					internal static var settingsIcon: _ImageResource {
						.init(
							name: "settings-icon",
							bundle: .module
						)
					}
				}
			}
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rejectsConflictingAccessorAndFolderNamespace() throws {
		let resources = [
			PackageResources.Image.Source(name: "Toolbar"),
			.init(
				name: "settings-icon",
				path: ["Toolbar"]
			)
		]

		for resources in [resources, resources.reversed()] {
			do {
				_ = try PackageResources.Image.Source.render(Array(resources))
				Issue.record("Expected conflicting image resource namespaces to throw.")
			} catch let error as ImageResourceValidationError {
				expectNoDifference(
					.conflictingNamespaces([
						.init(accessorName: "Toolbar", namespaceName: "settings-icon")
					]),
					error
				)
			} catch {
				Issue.record("Expected ImageResourceValidationError, got \(error).")
			}
		}
	}
}
