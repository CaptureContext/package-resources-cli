import Dependencies

extension Snippets {
	public struct PropertyDecl: Snippet {
		let isStatic: Bool
		let identifier: any Snippet
		let returnType: any Snippet
		let body: any Snippet

		init(
			isStatic: Bool = true,
			identifier: any Snippet,
			returnType: any Snippet,
			body: any Snippet
		) {
			self.isStatic = isStatic
			self.identifier = identifier
			self.returnType = returnType
			self.body = body
		}

		@Dependency(\.formatClient.indentUp)
		private var indent

		@Dependency(\.formatClient.constants.accessLevel)
		private var accessLevel

		public func render() -> String {
			renderSnippet(.join(" ") {
				renderSnippet(accessLevel)
				if isStatic { "static" }
				"var"
				renderSnippet(.join {
					identifier
					":"
				})
				returnType
				renderSnippet(.bracketedBlock(
					in: .curly(),
					contents: body
				))
			})
		}
	}
}

extension Snippet where Self == Snippets.PropertyDecl {
	public static func propertyDecl(
		isStatic: Bool = true,
		identifier: any Snippet,
		returnType: any Snippet,
		body: any Snippet
	) -> Self {
		.init(
			isStatic: isStatic,
			identifier: identifier,
			returnType: returnType,
			body: body
		)
	}
}
