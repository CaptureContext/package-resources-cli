import Dependencies
import Foundation
import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Image.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		@Dependency(\.resourceFormatConfig)
		var resourceFormatConfig
		let format = resourceFormatConfig.resolved(for: .images)

		let snippet = try Snippets.ImagesExtension(
			for: resources,
			format: format
		)

		return renderPackageResourceSnippet(snippet)
	}
}

struct ImageResourceNamespaceConflict: Equatable, Sendable {
	var accessorName: String
	var namespaceName: String
}

enum ImageResourceValidationError: CustomStringConvertible, Equatable, LocalizedError {
	case conflictingNamespaces([ImageResourceNamespaceConflict])

	var description: String {
		errorDescription ?? "Image resource validation error."
	}

	var errorDescription: String? {
		switch self {
		case let .conflictingNamespaces(conflicts):
			let conflictDescriptions = conflicts
				.map { conflict in
					"""
					"\(conflict.accessorName)" conflicts with "\(conflict.namespaceName)"
					"""
				}
				.joined(separator: ", ")

			return """
			Image resource namespace conflict: \(conflictDescriptions). \
			The accessor would be generated where the nested resource path needs an enum namespace.
			"""
		}
	}
}

private struct ImageNode {
	var children: [String: ImageNode] = [:]
	var resources: [PackageResources.Image.Source] = []

	mutating func insert(
		_ resource: PackageResources.Image.Source,
		path: ArraySlice<String>,
		format: ResourceFormatConfig.Resolved
	) throws {
		guard let pathComponent = path.first else {
			if let child = children.first(where: { child in
				packageResourceIdentifierValue(child.key) == imageAccessorIdentifier(
					for: resource,
					format: format
				)
			}) {
				throw ImageResourceValidationError.conflictingNamespaces([
					.init(
						accessorName: resource.name,
						namespaceName: child.value.firstResource?.name ?? child.key
					)
				])
			}

			resources.append(resource)
			return
		}

		if let existingResource = resources.first(where: { resource in
			imageAccessorIdentifier(
				for: resource,
				format: format
			) == packageResourceIdentifierValue(pathComponent)
		}) {
			throw ImageResourceValidationError.conflictingNamespaces([
				.init(
					accessorName: existingResource.name,
					namespaceName: resource.name
				)
			])
		}

		try children[pathComponent, default: .init()]
			.insert(
				resource,
				path: path.dropFirst(),
				format: format
			)
	}

	var firstResource: PackageResources.Image.Source? {
		resources.first
			?? children
				.sorted { $0.key < $1.key }
				.lazy
				.compactMap(\.value.firstResource)
				.first
	}
}

private func imageAccessorIdentifier(
	for source: PackageResources.Image.Source,
	format: ResourceFormatConfig.Resolved
) -> String {
	let key = format.splitByKeyPath
		? source.name.keyPathComponents.last
		: source.name

	return packageResourceIdentifierValue(key ?? source.name)
}

extension Snippets {
	fileprivate struct ImagesExtension: Snippet {
		let root: ImageNode
		let resources: [PackageResources.Image.Source]
		let format: ResourceFormatConfig.Resolved

		init(
			for resources: [PackageResources.Image.Source],
			format: ResourceFormatConfig.Resolved
		) throws {
			var root = ImageNode()

			for resource in resources {
				try root.insert(
					resource,
					path: Self.path(for: resource, format: format)[...],
					format: format
				)
			}

			self.root = root
			self.resources = resources
			self.format = format
		}

		var typeName: String {
			PackageResources.Image.typeName
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				if shouldGroup {
					ImageNodeContents(
						root,
						resourceTypeName: typeName,
						usesExplicitResourceType: false
					)
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

		private static func path(
			for resource: PackageResources.Image.Source,
			format: ResourceFormatConfig.Resolved
		) -> [String] {
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
		let resourceTypeName: String
		let usesExplicitResourceType: Bool

		init(
			_ node: ImageNode,
			resourceTypeName: String,
			usesExplicitResourceType: Bool
		) {
			self.node = node
			self.resourceTypeName = resourceTypeName
			self.usesExplicitResourceType = usesExplicitResourceType
		}

		var content: some Snippet<String> {
			Join(.const(.newlines(2))) {
				node.children
					.sorted { $0.key < $1.key }
					.map { name, child in
						ImageNodeEnum(
							name: name,
							node: child,
							resourceTypeName: resourceTypeName
						)
					}

				node.resources.map {
					ImageComputedProperty(
						for: $0,
						resourceTypeName: usesExplicitResourceType ? resourceTypeName : "Self"
					)
				}
			}
		}
	}

	private struct ImageNodeEnum: Snippet {
		let name: String
		let node: ImageNode
		let resourceTypeName: String

		var content: some Snippet<String> {
			EnumDecl(
				accessLevel: .current,
				identifier: packageResourceIdentifier(name)
			) {
				ImageNodeContents(
					node,
					resourceTypeName: resourceTypeName,
					usesExplicitResourceType: true
				)
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
				resources.map { ImageComputedProperty(for: $0, resourceTypeName: "Self") }
			}
		}
	}

	private struct ImageComputedProperty: Snippet {
		let resource: PackageResources.Image.Source
		let resourceTypeName: String

		init(
			for resource: PackageResources.Image.Source,
			resourceTypeName: String
		) {
			self.resource = resource
			self.resourceTypeName = resourceTypeName
		}

		var content: some Snippet<String> {
			ComputedPropertyDecl(
				accessLevel: .current,
				isStatic: true,
				identifier: packageResourceIdentifier(identifierName),
				type: TypeExpr(snippetLiteral: resourceTypeName),
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
