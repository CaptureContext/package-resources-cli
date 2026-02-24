import Foundation

struct ANSI: RawRepresentable, LosslessStringConvertible {
	let rawValue: String

	init(rawValue: String) {
		self.rawValue = rawValue
	}

	init(_ description: String) {
		self.init(rawValue: description)
	}

	var description: String { rawValue }

	private func _applying(_ styles: ANSI.Style...) -> Self {
		_applying(styles)
	}

	private func _applying(_ styles: [ANSI.Style]) -> Self {
		.init(rawValue: styles.reduce(rawValue) { (result, style) in
			style.rawValue + result + ANSI.Style.reset.rawValue
		})
	}

	func reset() -> Self { _applying(.reset) }
	func bold() -> Self { _applying(.bold) }
	func italic() -> Self { _applying(.italic) }
	func underline() -> Self { _applying(.underline) }

	func foreground(_ color: Color) -> Self {
		_applying(.foreground(color))
	}

	func background(_ color: Color) -> Self {
		_applying(.background(color))
	}

	struct Style {
		private static func _ansi(_ styleCode: Int) -> Self {
			self._ansi(String(styleCode))
		}

		private static func _ansi(_ styleCode: String) -> Self {
			.init(rawValue: "\u{001B}[\(styleCode)m")
		}

		var rawValue: String

		init(rawValue: String) {
			self.rawValue = rawValue
		}

		static let reset     : Self = _ansi(0)
		static let bold      : Self = _ansi(1)
		static let italic    : Self = _ansi(3)
		static let underline : Self = _ansi(4)

		static func foreground(_ color: Color) -> Self {
		 _ansi("3\(color.rawValue)")
	 }

	 static func background(_ color: Color) -> Self {
		 _ansi("4\(color.rawValue)")
	 }
	}

	struct Color: RawRepresentable {
		let rawValue: Int

		init(rawValue: Int) {
			self.rawValue = rawValue
		}

		static let black: Self = .init(rawValue: 0)
		static let red: Self = .init(rawValue: 1)
		static let green: Self = .init(rawValue: 2)
		static let yellow: Self = .init(rawValue: 3)
		static let blue: Self = .init(rawValue: 4)
		static let white: Self = .init(rawValue: 7)
	}
}
