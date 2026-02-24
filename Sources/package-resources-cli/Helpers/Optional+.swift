extension Optional {
	func or(_ defaultValue: @autoclosure () throws -> Self) rethrows -> Self {
		try self.or(defaultValue)
	}

	func or(_ defaultValue: @autoclosure () throws -> Wrapped) rethrows -> Wrapped {
		try self.or(defaultValue)
	}

	func or(_ defaultValue: () throws -> Self) rethrows -> Self {
		try self ?? defaultValue()
	}

	func or(_ defaultValue: () throws -> Wrapped) rethrows -> Wrapped {
		try self ?? defaultValue()
	}
}
