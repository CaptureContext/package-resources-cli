import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Nib.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }
		return renderPackageResourceSnippet(Snippets.NibsExtension(for: resources))
	}
}

extension Snippets {
	fileprivate struct NibsExtension: Snippet {
		let resources: [PackageResources.Nib.Source]

		init(for resources: [PackageResources.Nib.Source]) {
			self.resources = resources
		}

		var typeName: String {
			PackageResources.Nib.typeName
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				NibComputedPropertiesList(for: resources)
			}
		}
	}

	private struct NibComputedPropertiesList: Snippet {
		let resources: [PackageResources.Nib.Source]

		init(for resources: [PackageResources.Nib.Source]) {
			self.resources = resources
		}

		var content: some Snippet<String> {
			Join(.const(.newlines(2))) {
				resources.map { NibComputedProperty(for: $0) }
			}
		}
	}

	private struct NibComputedProperty: Snippet {
		let resource: PackageResources.Nib.Source

		init(for resource: PackageResources.Nib.Source) {
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
