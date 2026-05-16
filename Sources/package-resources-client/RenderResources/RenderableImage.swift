import Dependencies
import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Image.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		@Dependency(\.resourceFormatConfig)
		var resourceFormatConfig
		let format = resourceFormatConfig.resolved(for: .images)

		return renderPackageResourceSnippet(
			Snippets.ImagesExtension(
				for: resources,
				groupByCatalogName: format.groupByCatalogName
			)
		)
	}
}

private struct ImageNode {
	var children: [String: ImageNode] = [:]
	var resources: [PackageResources.Image.Source] = []

	mutating func insert(
		_ resource: PackageResources.Image.Source,
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
	fileprivate struct ImagesExtension: Snippet {
		let resources: [PackageResources.Image.Source]
		let groupByCatalogName: Bool

		init(
			for resources: [PackageResources.Image.Source],
			groupByCatalogName: Bool
		) {
			self.resources = resources
			self.groupByCatalogName = groupByCatalogName
		}

		var typeName: String {
			PackageResources.Image.typeName
		}

		var root: ImageNode {
			var root = ImageNode()
			for resource in resources {
				root.insert(resource, path: resource.path[...])
			}
			return root
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				if groupByCatalogName {
					ImageNodeContents(root)
				} else {
					ImageComputedPropertiesList(for: resources)
				}
			}
		}
	}

	private struct ImageNodeContents: Snippet {
		let node: ImageNode

		init(_ node: ImageNode) {
			self.node = node
		}

		var content: some Snippet<String> {
			Join(.const(.newlines(2))) {
				node.children
					.sorted { $0.key < $1.key }
					.map { name, child in
						ImageNodeEnum(name: name, node: child)
					}

				node.resources.map { ImageComputedProperty(for: $0) }
			}
		}
	}

	private struct ImageNodeEnum: Snippet {
		let name: String
		let node: ImageNode

		var content: some Snippet<String> {
			EnumDecl(
				accessLevel: .current,
				identifier: packageResourceIdentifier(name)
			) {
				ImageNodeContents(node)
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
