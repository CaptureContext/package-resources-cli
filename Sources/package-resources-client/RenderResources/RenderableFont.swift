import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Font.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		return renderPackageResourceSnippet(
			Snippets.Join(String.const(.newlines(2))) {
				Snippets.FontHelpersExtension(for: resources)
				Snippets.FontsExtension(for: resources)
			}
		)
	}
}

extension Snippets {
	fileprivate struct FontHelpersExtension: Snippet {
		let resources: [PackageResources.Font.Source]

		init(for resources: [PackageResources.Font.Source]) {
			self.resources = resources
		}

		var content: some Snippet<String> {
			ExtensionDecl(
				extendedType: .init(
					snippetLiteral: "Array where Element == \(PackageResources.Font.typeName)"
				)
			) {
				ComputedPropertyDecl(
					accessLevel: .current,
					isStatic: true,
					identifier: packageResourceIdentifier("_customFonts"),
					type: TypeExpr(snippetLiteral: "Self"),
					getter: PropertyGetterDecl {
						Join(String.const(.whitespace)) {
							"return"
							ArrayLiteral(customFontReferences.map { $0.makeSnippet() })
						}
					}
				)
			}
		}

		private var customFontReferences: [String] {
			resources
				.map { ".\(packageResourceIdentifier($0.name).render())" }
				.sorted(by: <)
		}
	}

	fileprivate struct FontsExtension: Snippet {
		let resources: [PackageResources.Font.Source]

		init(for resources: [PackageResources.Font.Source]) {
			self.resources = resources
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: PackageResources.Font.typeName)) {
				FontComputedPropertiesList(for: resources)
			}
		}
	}

	private struct FontComputedPropertiesList: Snippet {
		let resources: [PackageResources.Font.Source]

		init(for resources: [PackageResources.Font.Source]) {
			self.resources = resources
		}

		var content: some Snippet<String> {
			Join(String.const(.newlines(2))) {
				resources.map { FontComputedProperty(for: $0) }
			}
		}
	}

	private struct FontComputedProperty: Snippet {
		let resource: PackageResources.Font.Source

		init(for resource: PackageResources.Font.Source) {
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
							)
						])
					)
				}
			)
		}
	}
}
