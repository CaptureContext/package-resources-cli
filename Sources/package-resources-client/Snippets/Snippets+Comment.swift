extension Snippets {
	public struct Comment: Snippet {
		public enum Kind: String, Sendable {
			case doc = "///"
			case basic = "//"
		}

		let kind: Kind
		let contents: any Snippet

		init(
			kind: Kind,
			contents: any Snippet
		) {
			self.kind = kind
			self.contents = contents
		}

		public func render() -> String {
			contents.render()
				.components(separatedBy: .newlines)
				.map { line in
					if line.isEmpty {
						return kind.rawValue
					} else {
						return "\(kind.rawValue) \(line)"
					}
				}
				.joined(separator: "\n")
		}
	}
}

extension Snippet where Self == Snippets.Comment {
	public static func comment(
		_ contents: any Snippet
	) -> Self {
		.init(
			kind: .basic,
			contents: contents
		)
	}

	public static func docComment(
		_ contents: any Snippet
	) -> Self {
		.init(
			kind: .doc,
			contents: contents
		)
	}
}
