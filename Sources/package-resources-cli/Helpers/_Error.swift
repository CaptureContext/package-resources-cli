import Foundation

struct _Error: LocalizedError {
	let errorDescription: String

	init(_ description: String) {
		self.errorDescription = ANSI("💥 Error: ".appending(description))
			.foreground(.red)
			.bold()
			.description
	}
}
