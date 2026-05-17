import Dependencies
import Foundation
import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.SCNScene.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		@Dependency(\.resourceFormatConfig)
		var resourceFormatConfig
		let format = resourceFormatConfig.resolved(for: .scnScenes)

		let snippet = try Snippets.SCNScenesExtension(
			for: resources,
			format: format
		)

		return renderPackageResourceSnippet(snippet)
	}
}

struct SCNSceneResourceNamespaceConflict: Equatable, Sendable {
	var accessorName: String
	var namespaceName: String
}

enum SCNSceneResourceValidationError: CustomStringConvertible, Equatable, LocalizedError {
	case conflictingNamespaces([SCNSceneResourceNamespaceConflict])

	var description: String {
		errorDescription ?? "SCNScene resource validation error."
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
			SCNScene resource namespace conflict: \(conflictDescriptions). \
			The accessor would be generated where the nested resource path needs an enum namespace.
			"""
		}
	}
}

private struct SCNSceneNode {
	var children: [String: SCNSceneNode] = [:]
	var resources: [PackageResources.SCNScene.Source] = []

	mutating func insert(
		_ resource: PackageResources.SCNScene.Source,
		path: ArraySlice<String>,
		format: ResourceFormatConfig.Resolved
	) throws {
		guard let pathComponent = path.first else {
			if let child = children.first(where: { child in
				packageResourceIdentifierValue(child.key) == scnSceneAccessorIdentifier(
					for: resource,
					format: format
				)
			}) {
				throw SCNSceneResourceValidationError.conflictingNamespaces([
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
			scnSceneAccessorIdentifier(
				for: resource,
				format: format
			) == packageResourceIdentifierValue(pathComponent)
		}) {
			throw SCNSceneResourceValidationError.conflictingNamespaces([
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

	var firstResource: PackageResources.SCNScene.Source? {
		resources.first
			?? children
				.sorted { $0.key < $1.key }
				.lazy
				.compactMap(\.value.firstResource)
				.first
	}
}

private func scnSceneAccessorIdentifier(
	for source: PackageResources.SCNScene.Source,
	format: ResourceFormatConfig.Resolved
) -> String {
	let key = format.splitByKeyPath
		? source.name.keyPathComponents.last
		: source.name

	return packageResourceIdentifierValue(key ?? source.name)
}

extension Snippets {
	fileprivate struct SCNScenesExtension: Snippet {
		let root: SCNSceneNode
		let resources: [PackageResources.SCNScene.Source]
		let format: ResourceFormatConfig.Resolved

		init(
			for resources: [PackageResources.SCNScene.Source],
			format: ResourceFormatConfig.Resolved
		) throws {
			var root = SCNSceneNode()

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
			PackageResources.SCNScene.typeName
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				if shouldGroup {
					SCNSceneNodeContents(
						root,
						resourceTypeName: typeName,
						usesExplicitResourceType: false
					)
				} else {
					SCNSceneComputedPropertiesList(for: resources)
				}
			}
		}

		private var shouldGroup: Bool {
			format.groupByCatalogName
				|| format.groupByFolders
				|| format.splitByKeyPath
		}

		private static func path(
			for resource: PackageResources.SCNScene.Source,
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

	private struct SCNSceneNodeContents: Snippet {
		let node: SCNSceneNode
		let resourceTypeName: String
		let usesExplicitResourceType: Bool

		init(
			_ node: SCNSceneNode,
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
						SCNSceneNodeEnum(
							name: name,
							node: child,
							resourceTypeName: resourceTypeName
						)
					}

				node.resources.map {
					SCNSceneComputedProperty(
						for: $0,
						resourceTypeName: usesExplicitResourceType ? resourceTypeName : "Self"
					)
				}
			}
		}
	}

	private struct SCNSceneNodeEnum: Snippet {
		let name: String
		let node: SCNSceneNode
		let resourceTypeName: String

		var content: some Snippet<String> {
			EnumDecl(
				accessLevel: .current,
				identifier: packageResourceIdentifier(name)
			) {
				SCNSceneNodeContents(
					node,
					resourceTypeName: resourceTypeName,
					usesExplicitResourceType: true
				)
			}
		}
	}

	private struct SCNSceneComputedPropertiesList: Snippet {
		let resources: [PackageResources.SCNScene.Source]

		init(for resources: [PackageResources.SCNScene.Source]) {
			self.resources = resources
		}

		var content: some Snippet<String> {
			Join(.const(.newlines(2))) {
				resources.map { SCNSceneComputedProperty(for: $0, resourceTypeName: "Self") }
			}
		}
	}

	private struct SCNSceneComputedProperty: Snippet {
		let resource: PackageResources.SCNScene.Source
		let resourceTypeName: String

		init(
			for resource: PackageResources.SCNScene.Source,
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
						clause: SwiftCallClause(callArguments)
					)
				}
			)
		}

		private var identifierName: String {
			@Dependency(\.resourceFormatConfig)
			var resourceFormatConfig
			let format = resourceFormatConfig.resolved(for: .scnScenes)

			if format.splitByKeyPath {
				return resource.name.keyPathComponents.last ?? resource.name
			} else {
				return resource.name
			}
		}

		private var callArguments: [SwiftCallArgument] {
			var arguments: [SwiftCallArgument] = [
				.init(
					label: .init("name"),
					value: resource.name.escapedUsingQuotes
				)
			]

			if let catalog = resource.catalog {
				arguments.append(
					.init(
						label: .init("catalog"),
						value: catalog.escapedUsingQuotes
					)
				)
			}

			arguments.append(
				.init(
					label: .init("bundle"),
					value: ".module"
				)
			)

			return arguments
		}
	}
}
