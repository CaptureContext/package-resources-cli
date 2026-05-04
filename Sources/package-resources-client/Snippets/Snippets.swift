import Dependencies
import ArrayBuilder

public enum Snippets {}

public protocol Snippet: Sendable {
	func render() -> String
}

public func renderSnippet(
	_ snippet: (any Snippet)?,
	prefix: any Snippet = "",
	suffix: any Snippet = ""
) -> String {
	let rendered = snippet?.render() ?? ""
	if rendered.isEmpty { return "" }
	else { return prefix.render() + rendered + suffix.render() }
}
