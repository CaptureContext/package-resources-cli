import Dependencies

extension Snippets {
	public struct EnumDecl: Snippet, Sendable {
		public let identifier: any Snippet
		public let contents: any Snippet

		public init(
			identifier: any Snippet,
			contents: any Snippet
		) {
			self.identifier = identifier
			self.contents = contents
		}

		@Dependency(\.formatClient.indentUp)
		private var indent

		@Dependency(\.formatClient.constants.accessLevel)
		private var accessLevel

		public func render() -> String {
			return renderSnippet(.join(" ") {
				renderSnippet(accessLevel)
				"enum"
				renderSnippet(identifier)
				renderSnippet(.bracketedBlock(
					in: .curly(),
					contents: contents
				))
			})
		}
	}
}

extension Snippet where Self == Snippets.EnumDecl {
	public static func enumDecl(
		name identifier: any Snippet,
		contents: any Snippet
	) -> Self {
		.init(
			identifier: identifier,
			contents: contents
		)
	}
}
