import PackageResourcesCore
import ArrayBuilder

extension PackageResources.SCNScene.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }
		
		return renderSnippet(.extensionDecl(
			name: PackageResources.SCNScene.typeName,
			contents: .join("\n\n") {
				resources.map { $0.render() }
			}
		))
	}

	private func render() -> String {
		renderSnippet(.propertyDecl(
			identifier: .identifier(name),
			returnType: "Self",
			body: .methodCall(
				name: ".init",
				args: Array<Snippets.MethodCall.Argument> {
					Snippets.MethodCall.Argument(
						name: "name",
						value: name.escapedUsingQuotes
					)
					if let catalog {
						Snippets.MethodCall.Argument(
							name: "catalog",
							value: catalog.escapedUsingQuotes
						)
					}
					Snippets.MethodCall.Argument(
						name: "bundle",
						value: ".module"
					)
				}
			)
		))
	}
}
