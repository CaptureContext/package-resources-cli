import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Storyboard.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }
		return renderPackageResourceSnippet(Snippets.StoryboardsExtension(for: resources))
	}
}

extension Snippets {
	fileprivate struct StoryboardsExtension: Snippet {
		let resources: [PackageResources.Storyboard.Source]

		init(for resources: [PackageResources.Storyboard.Source]) {
			self.resources = resources
		}

		var typeName: String {
			PackageResources.Storyboard.typeName
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				StoryboardComputedPropertiesList(for: resources)
			}
		}
	}

	private struct StoryboardComputedPropertiesList: Snippet {
		let resources: [PackageResources.Storyboard.Source]

		init(for resources: [PackageResources.Storyboard.Source]) {
			self.resources = resources
		}

		var content: some Snippet<String> {
			Join(.const(.newlines(2))) {
				resources.map { StoryboardComputedProperty(for: $0) }
			}
		}
	}

	private struct StoryboardComputedProperty: Snippet {
		let resource: PackageResources.Storyboard.Source

		init(for resource: PackageResources.Storyboard.Source) {
			self.resource = resource
		}

		var content: some Snippet<String> {
			ComputedPropertyDecl(
				accessLevel: .current,
				isStatic: true,
				identifier: packageResourceIdentifier(resource.name),
				type: TypeExpr(snippetLiteral: "Self"),
				getter: PropertyGetterDecl {
					CallExpr(
						callee: ".init",
						clause: SwiftCallClause([
							SwiftCallArgument(
								label: .init("name"),
								value: resource.name.escapedUsingQuotes
							),
							SwiftCallArgument(
								label: .init("bundle"),
								value: ".module"
							)
						])
					)
				}
			)
		}
	}
}
