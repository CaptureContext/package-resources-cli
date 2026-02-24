extension Optional {
	func or(_ defaultValue: @autoclosure () -> Self) -> Self {
		self ?? defaultValue()
	}

	func or(_ defaultValue: @autoclosure () -> Wrapped) -> Wrapped {
		self ?? defaultValue()
	}
}
