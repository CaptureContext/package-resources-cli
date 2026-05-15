import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Color.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }
		return renderPackageResourceSnippet(Snippets.ColorsExtension(for: resources))
	}
}

extension Snippets {
	fileprivate struct ColorsExtension: Snippet {
		let resources: [PackageResources.Color.Source]

		init(for resources: [PackageResources.Color.Source]) {
			self.resources = resources
		}

		var typeName: String {
			PackageResources.Color.typeName
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				ColorComputedPropertiesList(for: resources)
			}
		}
	}

	private struct ColorComputedPropertiesList: Snippet {
		let resources: [PackageResources.Color.Source]

		init(for resources: [PackageResources.Color.Source]) {
			self.resources = resources
		}

		var content: some Snippet<String> {
			Join(.const(.newlines(2))) {
				resources.map { ColorComputedProperty(for: $0) }
			}
		}
	}

	private struct ColorComputedProperty: Snippet {
		let resource: PackageResources.Color.Source

		init(for resource: PackageResources.Color.Source) {
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
