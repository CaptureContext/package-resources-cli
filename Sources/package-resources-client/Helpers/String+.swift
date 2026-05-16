import Foundation

extension String {
	var escapedUsingQuotes: String { "\"\(self)\"" }

	var keyPathComponents: [String] {
		let components = split(separator: ".").map(String.init)
		return components.isEmpty ? [self] : components
	}
}
