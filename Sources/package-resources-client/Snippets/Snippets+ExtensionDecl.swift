import Dependencies

extension Snippets {
	public struct ExtensionDecl: Snippet, Sendable {
		public let accessModifier: AccessLevel?
		public let identifier: any Snippet
		public let whereClause: any Snippet
		public let contents: any Snippet

		public init(
			accessModifier: AccessLevel? = nil,
			identifier: any Snippet,
			whereClause: (any Snippet)? = nil,
			contents: any Snippet
		) {
			self.accessModifier = accessModifier
			self.identifier = identifier
			self.whereClause = whereClause ?? ""
			self.contents = contents
		}

		@Dependency(\.formatClient.indentUp)
		private var indent

		public func render() -> String {
			return renderSnippet(.join(" ") {
				renderSnippet(accessModifier)

				"extension"

				renderSnippet(.join(" ") {
					identifier
					whereClause
				})

				renderSnippet(.bracketedBlock(
					in: .curly(),
					contents: contents
				))
			})
		}
	}
}

extension Snippet where Self == Snippets.ExtensionDecl {
	public static func extensionDecl(
		accessModifier: AccessLevel? = nil,
		name identifier: any Snippet,
		whereClause: (any Snippet)? = nil,
		contents: any Snippet
	) -> Self {
		.init(
			accessModifier: accessModifier,
			identifier: identifier,
			whereClause: whereClause,
			contents: contents
		)
	}
}
