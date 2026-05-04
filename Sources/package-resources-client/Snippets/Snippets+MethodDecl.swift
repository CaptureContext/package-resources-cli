import Dependencies

extension Snippets {
	public struct MethodDecl: Snippet {
		public struct Argument: Snippet, Sendable {
			public let label: (any Snippet)?
			public let name: any Snippet
			public let type: any Snippet

			init(
				label: (any Snippet)? = nil,
				name: any Snippet,
				type: any Snippet
			) {
				self.label = label
				self.name = name
				self.type = type
			}

			public func render() -> String {
				let label = label?.render()
				let name = name.render()

				if let label, label != name {
					return "\(label) \(name): \(type.render())"
				} else {
					return "\(name): \(type.render())"
				}
			}
		}

		let isStatic: Bool
		let identifier: any Snippet
		let arguments: [Argument]
		let effects: (any Snippet)?
		let returnType: (any Snippet)?
		let body: any Snippet

		init(
			isStatic: Bool = true,
			identifier: any Snippet,
			arguments: [Argument] = [],
			effects: (any Snippet)? = nil,
			returnType: (any Snippet)?,
			body: any Snippet
		) {
			self.isStatic = isStatic
			self.identifier = identifier
			self.arguments = arguments
			self.effects = effects
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
				"func"
				renderSnippet(identifier).appending(
					renderSnippet(.bracketedBlock(
						in: .parentheses,
						isMultiline: arguments.count > 1,
						contents: .join(",\n") {
							arguments
						}
					))
				)
				if let effects { effects }
				if let returnType {
					"->"
					returnType
				}
				renderSnippet(.bracketedBlock(
					in: .curly(),
					contents: body
				))
			})
		}
	}
}

extension Snippet where Self == Snippets.MethodDecl {
	public static func methodDecl(
		isStatic: Bool = true,
		identifier: any Snippet,
		arguments: [Self.Argument] = [],
		effects: (any Snippet)? = nil,
		returnType: (any Snippet)?,
		body: any Snippet
	) -> Self {
		.init(
			isStatic: isStatic,
			identifier: identifier,
			arguments: arguments,
			effects: effects,
			returnType: returnType,
			body: body
		)
	}
}
