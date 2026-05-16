import Casification
import Dependencies
import Snippets
import SwiftSnippets

internal typealias SwiftCallArgument = Snippets.CallArgument<String>
internal typealias SwiftCallClause = Snippets.CallClause<String>
internal typealias SwiftFunctionParameter = Snippets.FunctionParameter<String>
internal typealias SwiftFunctionParameterClause = Snippets.FunctionParameterClause<String>

internal func renderPackageResourceSnippet(
	_ snippet: some Snippet<String>
) -> String {
	@Dependency(\.resourceFormatConfig)
	var resourceFormatConfig

	return snippet
		.indentor(resourceFormatConfig.current.indentor.makeSnippet())
		.render()
}

internal func packageResourceIdentifier(
	_ rawValue: String
) -> Snippets.IdentifierLiteral<String> {
	.init(snippetLiteral: packageResourceIdentifierValue(rawValue))
}

internal func packageResourceIdentifierValue(_ rawValue: String) -> String {
	rawValue.case(.camel)
}

extension Optional<Snippets.AccessLevel<String>> {
	public static var current: Self {
		@Dependency(\.resourceFormatConfig)
		var resourceFormatConfig

		return resourceFormatConfig.current.accessLevel?.snippetAccessLevel
	}
}

private extension AccessLevel {
	var snippetAccessLevel: Snippets.AccessLevel<String> {
		switch self {
		case .private:
			return .private
		case .internal:
			return .internal
		case .package:
			return .package
		case .public:
			return .public
		}
	}
}
