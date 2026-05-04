import Dependencies

extension Snippets {
	public struct Identifier: Snippet {
		let name: any Snippet

		init(name: any Snippet) {
			self.name = name
		}

		@Dependency(\.formatClient.camelCase)
		private var camelCase

		public func render() -> String {
			camelCase(renderSnippet(name))
		}
	}
}

extension Snippet where Self == Snippets.Identifier {
	public static func identifier(_ name: any Snippet) -> Self {
		.init(name: name)
	}
}
