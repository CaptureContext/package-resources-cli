import ArgumentParser
import CasePaths

extension Manifest {
	@CasePathable
	public enum Indentor: RawRepresentable, Codable, Equatable, Sendable, LosslessStringConvertible {
		@TaskLocal
		@_spi(Internals)
		public static var current: Self = .default

		public static var `default`: Self { .alias(.default) }
		public static var tab: Self { .alias(.tab) }
		public static var whitespace: Self { .alias(.whitespace) }
		public static var empty: Self { .alias(.empty) }

		@CasePathable
		public enum Alias: String, CaseIterable, Sendable {
			/// Alias for `tab`
			case `default` = "default"

			/// Equivalent for `"\t"`
			case tab, tabs

			/// Equivalent for `" "`
			case whitespace, whitespaces, space, spaces

			/// Equivalent for `""`
			case empty, none

			public init?(_ value: String) {
				if let alias = Self(rawValue: value) {
					self = alias
				} else {
					switch value {
					case "\t":
						self = .tab
					case "":
						self = .empty
					case " ":
						self = .whitespace
					default:
						return nil
					}
				}
			}

			public var aliasedValue: Indentor.RawValue {
				switch self {
				case .default, .tabs: Self.tab.aliasedValue
				case .space, .spaces, .whitespaces: Self.whitespace.aliasedValue
				case .none: Self.empty.aliasedValue
				case .tab: "\t"
				case .empty: ""
				case .whitespace: " "
				}
			}
		}

		case alias(Alias)
		case value(String)

		/// Creates a new instance of this type from a string representation.
		///
		/// Prefers alias representation (i.e `"tab"` over `"\t"`)
		public init(_ description: String) {
			self = Alias(description)
				.map(Self.alias)
				.or(.value(description))
		}

		/// A textual representation of this instance.
		///
		/// Returns an alias name if present or rawValue otherwise
		public var description: String {
			switch self {
			case let .alias(alias): alias.rawValue
			case let .value(value): value
			}
		}

		/// Creates a new instance of this type from a string representation.
		///
		/// Prefers raw representation (i.e `"\t"` over `"tab"`)
		public init(rawValue: String) {
			self = Alias(rawValue: rawValue)
				.map(Self.alias)
				.or(.value(rawValue))
		}


		/// A textual representation of this instance.
		///
		/// Always returns raw string (i.e `"\t"` for `"tab"` alias)
		public var rawValue: String {
			switch self {
			case let .alias(alias): alias.aliasedValue
			case let .value(value): value
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			self.init(try container.decode(String.self))
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			if Manifest.encodeAliases, Manifest.Version.current.major > 2 {
				try container.encode(description)
			} else {
				try container.encode(rawValue)
			}
		}
	}
}

extension Manifest.Indentor: ExpressibleByArgument {
	/// Creates a new instance of this type from a command-line-specified argument.
	public init(argument: String) {
		self.init(argument)
	}

	/// The description of this instance to show as a default value in a
	/// command-line tool's help screen.
	public var defaultValueDescription: String {
		"Default value is \"\t\""
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
			Alias.tab.rawValue,
			Alias.whitespace.rawValue,
			Alias.empty.rawValue,
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
			Alias.default.rawValue: "Alias for \"tab\"",
			Alias.tab.rawValue: "Alias for \"\\t\"",
			Alias.whitespace.rawValue: "Alias for \" \"",
			Alias.empty.rawValue: "Alias for \"\"",
			"<string>": "Intentation symbol string (i.e. \"\\t\", \" \", \"\", \"  \")"
		]
	}
}
