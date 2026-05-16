import Foundation

struct _Error: LocalizedError {
	let errorDescription: String?

	init(_ description: String) {
		self.errorDescription = description
	}
}
