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
			$0.resourceFormatConfig = .standard(indentor: " ", indentSize: 2, accessLevel: .public)
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

	@Test
	func groupsColorsByXCAssetFolders() throws {
		let output = try PackageResources.Color.Source.render([
			.init(
				name: "AccentColor",
				path: ["Brand", "Primary"]
			)
		])

		let expected = """
		extension _ColorResource {
			internal enum brand {
				internal enum primary {
					internal static var accentColor: _ColorResource {
						.init(
							name: "AccentColor",
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
	func rejectsConflictingAccessorAndNestedKeyPaths() throws {
		let resources = [
			PackageResources.Color.Source(name: "some.key"),
			.init(name: "some.key.label")
		]

		for resources in [resources, resources.reversed()] {
			do {
				_ = try PackageResources.Color.Source.render(Array(resources))
				Issue.record("Expected conflicting color resource namespaces to throw.")
			} catch let error as ColorResourceValidationError {
				expectNoDifference(
					.conflictingNamespaces([
						.init(accessorName: "some.key", namespaceName: "some.key.label")
					]),
					error
				)
			} catch {
				Issue.record("Expected ColorResourceValidationError, got \(error).")
			}
		}
	}
}
