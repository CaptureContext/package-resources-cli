import Dependencies
import ArrayBuilder

extension Snippets {
	public struct MethodCall: Snippet {
		public struct Argument: Snippet {
			 let name: (any Snippet)?
			 let value: any Snippet

			 public init(
				 name: (any Snippet)? = nil,
				 value: any Snippet
			 ) {
				 self.name = name
				 self.value = value
			 }

			 public init(
				 _ name: (any Snippet)?,
				 value: any Snippet
			 ) {
				 self.init(
					 name: name,
					 value: value
				 )
			 }

			 public func render() -> String {
				 renderSnippet(.join(": ") {
					 renderSnippet(name)
					 renderSnippet(value)
				 })
			 }
		 }

		public struct ArgumentsList: Snippet {
			let isMultiline: Bool
			let items: [Argument]

			public init(
				isMultiline: Bool = true,
				items: [Argument]
			) {
				self.isMultiline = isMultiline
				self.items = items
			}

			public func render() -> String {
				renderSnippet(.join(isMultiline ? ",\n" : ", ") {
					items
				})
			}
		}

		let name: any Snippet
		let args: ArgumentsList

		public init(
			name: any Snippet,
			args: ArgumentsList
		) {
			self.name = name
			self.args = args
		}

		public func render() -> String {
			renderSnippet(.join {
				renderSnippet(name)
				renderSnippet(.bracketedBlock(
					in: .parentheses,
					isMultiline: args.isMultiline,
					contents: args
				))
			})
		}
	}
}

extension Snippet where Self == Snippets.MethodCall {
	public static func methodCall(
		name: any Snippet,
		isMultiline: Bool? = nil,
		args: [Self.Argument]
	) -> Self {
		.init(
			name: name,
			args: .init(
				isMultiline: isMultiline ?? (args.count > 1),
				items: args
			)
		)
	}
}

extension Snippet where Self == Snippets.MethodCall.Argument {
	public static func callArgument(
		name: any Snippet = "",
		value: String
	) -> Self {
		.init(
			name: name,
			value: value
		)
	}
}

extension Snippet where Self == Snippets.MethodCall.ArgumentsList {
	public static func callArguments(
		isMultiline: Bool = true,
		@ArrayBuilder<Snippets.MethodCall.Argument> args: () -> [Snippets.MethodCall.Argument]
	) -> Self {
		.init(
			isMultiline: isMultiline,
			items: args()
		)
	}
}
