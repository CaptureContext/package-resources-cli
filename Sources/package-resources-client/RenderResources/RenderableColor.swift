import Dependencies
import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Color.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		@Dependency(\.resourceFormatConfig)
		var resourceFormatConfig
		let format = resourceFormatConfig.resolved(for: .colors)

		return renderPackageResourceSnippet(
			Snippets.ColorsExtension(
				for: resources,
				groupByCatalogName: format.groupByCatalogName
			)
		)
	}
}

private struct ColorNode {
	var children: [String: ColorNode] = [:]
	var resources: [PackageResources.Color.Source] = []

	mutating func insert(
		_ resource: PackageResources.Color.Source,
		path: ArraySlice<String>
	) {
		guard let pathComponent = path.first else {
			resources.append(resource)
			return
		}

		children[pathComponent, default: .init()]
			.insert(resource, path: path.dropFirst())
	}
}

extension Snippets {
	fileprivate struct ColorsExtension: Snippet {
		let resources: [PackageResources.Color.Source]
		let groupByCatalogName: Bool

		init(
			for resources: [PackageResources.Color.Source],
			groupByCatalogName: Bool
		) {
			self.resources = resources
			self.groupByCatalogName = groupByCatalogName
		}

		var typeName: String {
			PackageResources.Color.typeName
		}

		var root: ColorNode {
			var root = ColorNode()
			for resource in resources {
				root.insert(resource, path: resource.path[...])
			}
			return root
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				if groupByCatalogName {
					ColorNodeContents(root)
				} else {
					ColorComputedPropertiesList(for: resources)
				}
			}
		}
	}

	private struct ColorNodeContents: Snippet {
		let node: ColorNode

		init(_ node: ColorNode) {
			self.node = node
		}

		var content: some Snippet<String> {
			Join(.const(.newlines(2))) {
				node.children
					.sorted { $0.key < $1.key }
					.map { name, child in
						ColorNodeEnum(name: name, node: child)
					}

				node.resources.map { ColorComputedProperty(for: $0) }
			}
		}
	}

	private struct ColorNodeEnum: Snippet {
		let name: String
		let node: ColorNode

		var content: some Snippet<String> {
			EnumDecl(
				accessLevel: .current,
				identifier: packageResourceIdentifier(name)
			) {
				ColorNodeContents(node)
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
