import PackageResourcesCore
import Dependencies

extension PackageResources.Font.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		let extras: some Snippet = .extensionDecl(
			name: "Array",
			whereClause: "where Element == \(PackageResources.Font.typeName)",
			contents: .propertyDecl(
				identifier: "_customFonts",
				returnType: "Self",
				body: .join(" ") {
					"return"
					renderSnippet(.bracketedBlock(
						in: .square,
						contents: .callArguments {
							resources
								.map { "." + renderSnippet(.identifier($0.name)) }
								.sorted(by: <)
								.map { .callArgument(value: $0) }
						}
					))
				}
			)
		)

		let accessors: some Snippet = .extensionDecl(
			name: PackageResources.Font.typeName,
			contents: .join("\n\n") {
				resources.map { $0.render() }
			}
		)

		return renderSnippet(.join("\n\n") {
			extras
			accessors
		})
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
				]
			)
		))
	}
}
