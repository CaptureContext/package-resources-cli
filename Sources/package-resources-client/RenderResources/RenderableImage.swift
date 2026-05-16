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
				format: format
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
		let format: ResourceFormatConfig.Resolved

		init(
			for resources: [PackageResources.Image.Source],
			format: ResourceFormatConfig.Resolved
		) {
			self.resources = resources
			self.format = format
		}

		var typeName: String {
			PackageResources.Image.typeName
		}

		var root: ImageNode {
			var root = ImageNode()
			for resource in resources {
				root.insert(resource, path: path(for: resource)[...])
			}
			return root
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				if shouldGroup {
					ImageNodeContents(root)
				} else {
					ImageComputedPropertiesList(for: resources)
				}
			}
		}

		private var shouldGroup: Bool {
			format.groupByCatalogName
				|| format.groupByFolders
				|| format.splitByKeyPath
		}

		private func path(for resource: PackageResources.Image.Source) -> [String] {
			var path: [String] = []
			if format.groupByCatalogName, let catalog = resource.catalog {
				path.append(catalog)
			}
			if format.groupByFolders {
				path.append(contentsOf: resource.path)
			}

			if format.splitByKeyPath {
				path = path.flatMap(\.keyPathComponents)
				let namePath = resource.name.keyPathComponents
				path.append(contentsOf: namePath.dropLast())
			}

			return path
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
				identifier: packageResourceIdentifier(identifierName),
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

		private var identifierName: String {
			@Dependency(\.resourceFormatConfig)
			var resourceFormatConfig
			let format = resourceFormatConfig.resolved(for: .images)

			if format.splitByKeyPath {
				return resource.name.keyPathComponents.last ?? resource.name
			} else {
				return resource.name
			}
		}
	}
}
