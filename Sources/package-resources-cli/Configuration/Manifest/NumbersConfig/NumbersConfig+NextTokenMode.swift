import Casification
import CasePaths
import ArgumentParser

extension Manifest.NumbersConfig {
	/// CamelCase mode for a token after a number
	@CasePathable
	public enum NextTokenMode: RawRepresentable, Codable, Sendable, LosslessStringConvertible {
		public typealias RawValue = String.Casification.Configuration.CamelCase.Numbers.NextTokenMode

		public static var `default`: Self { .alias(.default) }
		public static var current: Self { .alias(.current) }

		@CasePathable
		public enum Alias: String, CaseIterable, Sendable {
			/// Default value. Equivalent to `inherit`
			case `default`

			/// Equivalent to default value
			case current

			/// Uses value from the context. Contextual value is `automatic`
			case inherit

			/// Alias for `automatic`
			case auto

			///Applies pascal or camel mode to a first token after a number, depending on the case of the first letter character in the input string.
			case automatic

			/// Lowercases first token after a number unconditionally
			case camel

			/// Uppercases the first letter of a first token after a number for `word` tokens, or applies appropriate pascal-case transformation for `acronym` tokens
			case pascal

			public init(
				_ mode: NextTokenMode.RawValue
			) {
				self = switch mode {
				case .inherit: .inherit
				case .override(.automatic): .automatic
				case .override(.camel): .camel
				case .override(.pascal): .pascal
				}
			}

			public var aliasedValue: NextTokenMode.RawValue {
				switch self {
				case .default: return .default
				case .current: return .current
				case .inherit: return .inherit
				case .automatic, .auto: return .override(.automatic)
				case .camel: return .override(.camel)
				case .pascal: return .override(.pascal)
				}
			}
		}

		case alias(Alias)

		/// Creates a new instance of this type from a string representation.
		public init?(_ description: String) {
			if let alias = Alias(rawValue: description.lowercased()) {
				self = .alias(alias)
			} else {
				return nil
			}
		}

		/// A textual representation of this instance.
		public var description: String {
			switch self {
			case let .alias(alias): alias.rawValue
			}
		}

		/// Creates a new instance of this type from an actual mode
		public init(rawValue: RawValue) {
			self = .alias(.init(rawValue))
		}

		/// Associated NextTokenMode
		public var rawValue: RawValue {
			switch self {
			case let .alias(alias): alias.aliasedValue
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			let description = try container.decode(String.self)
			if let alias = Alias(rawValue: description) {
				self = .alias(alias)
			} else {
				throw _Error("Got unexpected value \"\(description)\" for numbers.next-token-mode")
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			if !Manifest.encodeAliases {
				try container.encode(Alias(self.rawValue).rawValue)
			} else {
				try container.encode(description)
			}
		}
	}
}

extension Manifest.NumbersConfig.NextTokenMode: ExpressibleByArgument {
	/// Creates a new instance of this type from a command-line-specified argument.
	public init?(argument: String) {
		self.init(argument)
	}

	/// The description of this instance to show as a default value in a
	/// command-line tool's help screen.
	public var defaultValueDescription: String {
		"Default value is \"inherit\"."
	}

	/// An array of all possible strings that can convert to a value of this
	/// type, for display in the help screen.
	///
	/// The default implementation of this property returns an empty array. If the
	/// conforming type is also `CaseIterable`, the default implementation returns
	/// an array with a value for each case.
	public static var allValueStrings: [String] {
		Alias.allCases.map(\.rawValue)
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
			Alias.default.rawValue: "Default value. Equivalent to \"inherit\".",
			Alias.current.rawValue: "Equivalent to default value.",
			Alias.inherit.rawValue: "Uses value from the context. Contextual value is \"automatic\".",
			Alias.auto.rawValue: "Alias for \"automatic\".",
			Alias.automatic.rawValue: "Applies \"pascal\" or \"camel\" mode to a first token after a number, depending on the case of the first letter character in the input string.",
			Alias.camel.rawValue: "Lowercases first token after a number unconditionally",
			Alias.pascal.rawValue: "Uppercases the first letter of a first token after a number for `word` tokens, or applies appropriate pascal-case transformation for `acronym` tokens"
		]
	}
}

