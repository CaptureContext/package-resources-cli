import Dependencies

extension Snippets {
	public struct Indent: Snippet {
		let level: Int
		let contents: any Snippet

		public init(
			level: Int,
			contents: any Snippet
		) {
			self.level = level
			self.contents = contents
		}

		@Dependency(\.formatClient.indentUp)
		var indent

		public func render() -> String {
			indent(level)(renderSnippet(contents))
		}
	}
}

extension Snippet {
	public func indented(by level: Int = 1) -> Snippets.Indent {
		.init(level: level, contents: self)
	}
}
