import ArgumentParser

extension Manifest {
	/// Manifest version
	///
	/// Used to manage `encoding`&`decoding` of the manifest
	/// in a more stable way
	public struct Version: Codable, Sendable, RawRepresentable, LosslessStringConvertible {
		@TaskLocal
		static var current: Self = .init(major: 3, minor: 0)

		public let major: Int
		public let minor: Int

		/// Textual representation of this
		public var rawValue: String { "\(major).\(minor)" }

		/// A textual representation of this instance.
		public var description: String { rawValue }

		/// Creates a new instance of this type from a string representation.
		public init?(_ versionString: String) {
			self.init(rawValue: versionString)
		}

		/// Creates a new instance of this type from a raw version string
		///
		/// - Note: Format of the input string doesn't support `<patch>` components
		///         input has to be either `<major>.<minor>` or just `<major>`.
		///         Version tags are also NOT supported, both components must be valid integers.
		public init?(rawValue: String) {
			let parts = rawValue.split(separator: ".").map { Int($0) }
			guard
				[1, 2].contains(parts.count),
				let majorPart = parts.first,
				let major = majorPart
			else { return nil }

			var minor = 0
			if parts.count == 2, let minorPart = parts.last {
				if let value = minorPart {
					minor = value
				} else {
					return nil
				}
			}

			self.init(
				major: major,
				minor: minor
			)
		}

		/// Creates a new instance of this type from explicitly
		/// defined `<major>` and `<minor>` version comonents
		public init(major: Int, minor: Int = 0) {
			self.major = major
			self.minor = minor
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			let rawValue = try container.decode(String.self)

			guard let version = Self(rawValue: rawValue)
			else { throw _Error("Manifest version corrupted") }

			self = version
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode("\(major).\(minor)")
		}
	}
}

extension Manifest.Version: ExpressibleByArgument {
	/// Creates a new instance of this type from a command-line-specified argument.
	public init?(argument: String) {
		self.init(argument)
	}

	public static var allValueStrings: [String] {
		["1", "2"]
	}

	public static var allValueDescriptions: [String : String] {
		[
			"1.0": "Manifest format version 1.0. Supports basic indentation and acronym overrides",
			"2.0": "Manifest format version 2.0. Supports advanced numeric and acronym overrides. Compatibility with v1 is limited."
		]
	}
}
