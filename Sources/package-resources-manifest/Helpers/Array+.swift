extension Array where Self: Hashable {
	func uniqued() -> [Element] { uniqued(by: \.self) }
}

extension Array {
	func uniqued<Key: Hashable>(by id: (Element) -> Key) -> [Element] {
		var set: Set<Key> = []
		return filter { set.insert(id($0)).inserted }
	}
}
