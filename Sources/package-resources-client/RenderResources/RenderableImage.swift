import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Image.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }
		return renderPackageResourceSnippet(Snippets.ImagesExtension(for: resources))
	}
}

extension Snippets {
	fileprivate struct ImagesExtension: Snippet {
		let resources: [PackageResources.Image.Source]

		init(for resources: [PackageResources.Image.Source]) {
			self.resources = resources
		}

		var typeName: String {
			PackageResources.Image.typeName
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				ImageComputedPropertiesList(for: resources)
			}
		}
	}

	private struct ImageComputedPropertiesList: Snippet {
		let resources: [PackageResources.Image.Source]

		init(for resources: [PackageResources.Image.Source]) {
			self.resources = resources
		}

		var content: some Snippet<String> {
			Join(.const(.newlines(2))) {
				resources.map { ImageComputedProperty(for: $0) }
			}
		}
	}

	private struct ImageComputedProperty: Snippet {
		let resource: PackageResources.Image.Source

		init(for resource: PackageResources.Image.Source) {
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
