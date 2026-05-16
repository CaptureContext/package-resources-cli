import ArgumentParser
import CasePaths

extension Manifest.NumbersConfig {
	@CasePathable
	public enum Separator: RawRepresentable, Codable, Equatable, Sendable {
		public static var `default`: Self { .alias(.default) }
		public static var current: Self { .alias(.current) }

		@CasePathable
		public enum Alias: String, CaseIterable, Sendable {
			case `default` = "default"
			case current
			case none

			public var aliasedValue: Separator.RawValue {
				switch self {
				case .default: String.Casification
						.Configuration.CamelCase
						.Numbers.default.separator
				case .current: String.Casification
						.Configuration.CamelCase
						.Numbers.current.separator
				case .none: ""
				}
			}
		}

		case alias(Alias)
		case value(Substring)

		/// Creates a new instance of this type from a string representation.
		public init(_ description: String) {
			if let alias = Alias(rawValue: description) {
				self = .alias(alias)
			} else {
				self = .value(description[...])
			}
		}

		/// A textual representation of this instance.
		public var description: String {
			switch self {
			case let .alias(alias): alias.rawValue
			case let .value(value): String(value)
			}
		}

		/// Creates a new instance of this type from a characters set representation
		public init(rawValue: Substring) {
			self = .value(rawValue)
		}

		/// Underlying set of allowed delimeters
		public var rawValue: Substring {
			switch self {
			case let .alias(alias): alias.aliasedValue
			case let .value(value): value
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			try self.init(container.decode(String.self))
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			if Manifest.encodeAliases, Manifest.Version.current.major > 1 {
				try container.encode(description)
			} else {
				try container.encode(String(rawValue.sorted()))
			}
		}
	}
}

extension Manifest.NumbersConfig.Separator: ExpressibleByArgument {
	/// Creates a new instance of this type from a command-line-specified argument.
	public init?(argument: String) {
		self.init(argument)
	}

	/// The description of this instance to show as a default value in a
	/// command-line tool's help screen.
	public var defaultValueDescription: String {
		"Default value is \"_\""
	}

	/// An array of all possible strings that can convert to a value of this
	/// type, for display in the help screen.
	///
	/// The default implementation of this property returns an empty array. If the
	/// conforming type is also `CaseIterable`, the default implementation returns
	/// an array with a value for each case.
	public static var allValueStrings: [String] {
		[
			Alias.default.rawValue,
			Alias.current.rawValue,
			Alias.none.rawValue,
			"<string>"
		]
	}


	/// A dictionary containing the descriptions for each possible value of this type,
	/// for display in the help screen.
	///
	/// The default implementation of this property returns an empty dictionary. If
	/// the conforming type is also `CaseIterable`, the default implementation
	/// returns a dictionary with a description for each value as its key-value pair.
	/// Note that the conforming type must implement the
	/// `defaultValueDescription` for each value - if the description and the
	/// value are the same string, it's assumed that a description is not implemented.
	public static var allValueDescriptions: [String: String] {
		[
			Alias.default.rawValue: "Equivalent to \"_\".",
			Alias.current.rawValue: "Equivalent to default value.",
			Alias.none.rawValue: "No separators",
			"<string>": "String representation of separator"
		]
	}
}
