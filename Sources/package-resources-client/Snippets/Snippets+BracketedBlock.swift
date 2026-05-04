import Dependencies

extension Snippets {
	public struct BracketedBlock: Snippet, Sendable {
		public struct Brackets: Sendable, ExpressibleByStringLiteral {
			let opening: any Snippet
			let closing: any Snippet

			public init(
				opening: any Snippet,
				closing: any Snippet
			) {
				self.opening = opening
				self.closing = closing
			}

			public init(_ value: any Snippet) {
				self.init(opening: value, closing: value)
			}

			public init(stringLiteral value: String) {
				self.init(value)
			}

			public static var parentheses: Self {
				.init(opening: "(", closing: ")")
			}

			public static var square: Self {
				.init(opening: "[", closing: "]")
			}

			public static func curly(
				openingSuffix: any Snippet = "",
				closingPrefix: any Snippet = ""
			) -> Self {
				.init(
					opening: "{" + openingSuffix.render(),
					closing:  closingPrefix.render() + "}"
				)
			}

			public static func backticks(_ count: Int = 1) -> Self {
				.init(String(repeating: "`", count: count))
			}

			public static var trippleQuotes: Self {
				.init("\"\"\"")
			}
		}

		let brackets: Brackets
		let isMultiline: Bool
		let indent: Bool
		let contents: any Snippet

		public init(
			brackets: Brackets,
			isMultiline: Bool,
			indent: Bool,
			contents: any Snippet
		) {
			self.brackets = brackets
			self.isMultiline = isMultiline
			self.indent = indent
			self.contents = contents
		}

		public func render() -> String {
			renderSnippet(.join(isMultiline ? "\n" : "") {
				brackets.opening
				if indent {
					contents.indented()
				} else {
					contents
				}
				brackets.closing
			})
		}
	}
}

extension Snippet where Self == Snippets.BracketedBlock {
	public static func bracketedBlock(
		in brackets: Self.Brackets,
		isMultiline: Bool = true,
		indent: Bool? = nil,
		contents: any Snippet
	) -> Self {
		.init(
			brackets: brackets,
			isMultiline: isMultiline,
			indent: indent ?? isMultiline,
			contents: contents
		)
	}
}
