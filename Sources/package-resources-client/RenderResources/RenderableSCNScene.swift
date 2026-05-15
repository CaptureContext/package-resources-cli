import PackageResourcesCore
import Snippets
import SwiftSnippets

extension PackageResources.SCNScene.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }
		return renderPackageResourceSnippet(Snippets.SCNScenesExtension(for: resources))
	}
}

extension Snippets {
	fileprivate struct SCNScenesExtension: Snippet {
		let resources: [PackageResources.SCNScene.Source]

		init(for resources: [PackageResources.SCNScene.Source]) {
			self.resources = resources
		}

		var typeName: String {
			PackageResources.SCNScene.typeName
		}

		var content: some Snippet<String> {
			ExtensionDecl(extendedType: .init(snippetLiteral: typeName)) {
				SCNSceneComputedPropertiesList(for: resources)
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
				resources.map { SCNSceneComputedProperty(for: $0) }
			}
		}
	}

	private struct SCNSceneComputedProperty: Snippet {
		let resource: PackageResources.SCNScene.Source

		init(for resource: PackageResources.SCNScene.Source) {
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
						clause: SwiftCallClause(callArguments)
					)
				}
			)
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
