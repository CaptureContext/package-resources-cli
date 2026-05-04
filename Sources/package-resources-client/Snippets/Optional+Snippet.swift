extension Optional: Snippet where Wrapped: Snippet {
	public func render() -> String {
		map { $0.render() } ?? ""
	}
}
