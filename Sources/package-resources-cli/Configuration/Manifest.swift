import Casification
import SystemConfiguration

public struct Manifest {
	public var version: Version
	public var output: String?
	public var indentor: String
	public var indentSize: Int

	public var camelCaseNumbers: CamelCaseConfig.Numbers
	public var camelCaseAcronyms: CamelCaseConfig.Acronyms
	public var commonNumbers: CommonCaseConfig.Numbers
	public var commonAcronyms: Set<Substring>

	public init(
		version: Version = .init(major: 2),
		output: String? = nil,
		indentor: String = "\t",
		indentSize: Int = 1,
		camelCaseNumbers: CamelCaseConfig.Numbers = .current,
		camelCaseAcronyms: CamelCaseConfig.Acronyms = .current,
		commonNumbers: CommonCaseConfig.Numbers = .current,
		commonAcronyms: Set<Substring> = .currentAcronyms
	) {
		self.version = version
		self.output = output
		self.indentor = indentor
		self.indentSize = indentSize
		self.camelCaseNumbers = camelCaseNumbers
		self.camelCaseAcronyms = camelCaseAcronyms
		self.commonNumbers = commonNumbers
		self.commonAcronyms = commonAcronyms
	}

	public struct Version: Codable, RawRepresentable {
		public let major: Int
		public let minor: Int

		public var rawValue: String { "\(major).\(minor)" }

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
