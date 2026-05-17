import Dependencies
import Foundation
import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.Color.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		@Dependency(\.resourceFormatConfig)
		var resourceFormatConfig
		let format = resourceFormatConfig.resolved(for: .colors)

		let snippet = try Snippets.ColorsExtension(
			for: resources,
			format: format
		)

		return renderPackageResourceSnippet(snippet)
	}
}

struct ColorResourceNamespaceConflict: Equatable, Sendable {
	var accessorName: String
	var namespaceName: String
}

enum ColorResourceValidationError: CustomStringConvertible, Equatable, LocalizedError {
	case conflictingNamespaces([ColorResourceNamespaceConflict])

	var description: String {
		errorDescription ?? "Color resource validation error."
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
			Color resource namespace conflict: \(conflictDescriptions). \
			The accessor would be generated where the nested resource path needs an enum namespace.
			"""
		}
	}
}

private struct ColorNode {
	var children: [String: ColorNode] = [:]
	var resources: [PackageResources.Color.Source] = []

	mutating func insert(
		_ resource: PackageResources.Color.Source,
		path: ArraySlice<String>,
		format: ResourceFormatConfig.Resolved
	) throws {
		guard let pathComponent = path.first else {
			if let child = children.first(where: { child in
				packageResourceIdentifierValue(child.key) == colorAccessorIdentifier(
					for: resource,
					format: format
				)
			}) {
				throw ColorResourceValidationError.conflictingNamespaces([
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
			colorAccessorIdentifier(
				for: resource,
				format: format
			) == packageResourceIdentifierValue(pathComponent)
		}) {
			throw ColorResourceValidationError.conflictingNamespaces([
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

	var firstResource: PackageResources.Color.Source? {
		resources.first
			?? children
				.sorted { $0.key < $1.key }
				.lazy
				.compactMap(\.value.firstResource)
				.first
	}
}

private func colorAccessorIdentifier(
	for source: PackageResources.Color.Source,
	format: ResourceFormatConfig.Resolved
) -> String {
	let key = format.splitByKeyPath
		? source.name.keyPathComponents.last
		: source.name

	return packageResourceIdentifierValue(key ?? source.name)
}

extension Snippets {
	fileprivate struct ColorsExtension: Snippet {
		let root: ColorNode
		let resources: [PackageResources.Color.Source]
		let format: ResourceFormatConfig.Resolved

		init(
			for resources: [PackageResources.Color.Source],
			format: ResourceFormatConfig.Resolved
		) throws {
			var root = ColorNode()

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
			PackageResources.Color.typeName
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				if shouldGroup {
					ColorNodeContents(
						root,
						resourceTypeName: typeName,
						usesExplicitResourceType: false
					)
				} else {
					ColorComputedPropertiesList(for: resources)
				}
			}
		}

		private var shouldGroup: Bool {
			format.groupByCatalogName
				|| format.groupByFolders
				|| format.splitByKeyPath
		}

		private static func path(
			for resource: PackageResources.Color.Source,
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

	private struct ColorNodeContents: Snippet {
		let node: ColorNode
		let resourceTypeName: String
		let usesExplicitResourceType: Bool

		init(
			_ node: ColorNode,
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
						ColorNodeEnum(
							name: name,
							node: child,
							resourceTypeName: resourceTypeName
						)
					}

				node.resources.map {
					ColorComputedProperty(
						for: $0,
						resourceTypeName: usesExplicitResourceType ? resourceTypeName : "Self"
					)
				}
			}
		}
	}

	private struct ColorNodeEnum: Snippet {
		let name: String
		let node: ColorNode
		let resourceTypeName: String

		var content: some Snippet<String> {
			EnumDecl(
				accessLevel: .current,
				identifier: packageResourceIdentifier(name)
			) {
				ColorNodeContents(
					node,
					resourceTypeName: resourceTypeName,
					usesExplicitResourceType: true
				)
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
				resources.map { ColorComputedProperty(for: $0, resourceTypeName: "Self") }
			}
		}
	}

	private struct ColorComputedProperty: Snippet {
		let resource: PackageResources.Color.Source
		let resourceTypeName: String

		init(
			for resource: PackageResources.Color.Source,
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
			let format = resourceFormatConfig.resolved(for: .colors)

			if format.splitByKeyPath {
				return resource.name.keyPathComponents.last ?? resource.name
			} else {
				return resource.name
			}
		}
	}
}
