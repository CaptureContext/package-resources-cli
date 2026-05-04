import ArrayBuilder

extension Snippets {
	public struct Join: Snippet {
		let separator: any Snippet
		let snippets: [any Snippet]

		public init(
			separator: any Snippet,
			snippets: [any Snippet]
		) {
			self.separator = separator
			self.snippets = snippets
		}

		public func render() -> String {
			snippets
				.compactMap {
					let rendered = renderSnippet($0)
					return rendered.isEmpty ? nil : rendered
				}
				.joined(separator: renderSnippet(separator))
		}
	}
}

extension Snippet where Self == Snippets.Join {
	public static func join(
		_ separator: any Snippet = "",
		@ArrayBuilder<any Snippet> snippets: () -> [any Snippet]
	) -> Self {
		.init(
			separator: separator,
			snippets: snippets()
		)
	}
}
