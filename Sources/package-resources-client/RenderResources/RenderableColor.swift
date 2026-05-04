import PackageResourcesCore

extension PackageResources.Color.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		return renderSnippet(.extensionDecl(
			name: PackageResources.Color.typeName,
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
				args: [
					.callArgument(
						name: "name",
						value: name.escapedUsingQuotes
					),
					.callArgument(
						name: "bundle",
						value: ".module"
					),
				]
			)
		))
	}
}
