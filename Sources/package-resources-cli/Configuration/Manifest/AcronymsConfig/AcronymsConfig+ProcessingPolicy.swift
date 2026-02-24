import Casification
import CasePaths
import ArgumentParser

extension Manifest.AcronymsConfig {
	/// CamelCase mode for a token after a number
	@CasePathable
	public enum ProcessingPolicy: RawRepresentable, Codable, Sendable, LosslessStringConvertible {
		public typealias RawValue = String.Casification.Configuration.CamelCase.Acronyms.ProcessingPolicy

		public static var `default`: Self { .alias(.default) }
		public static var current: Self { .alias(.current) }

		@CasePathable
		public enum Alias: String, CaseIterable, Sendable {
			/// Default value. Equivalent to `alwaysMatchCase`
			case `default`

			/// Equivalent to default value
			case current

			/// Keep acronyms as parsed
			///
			/// Examples:
			/// - `"ID"` → `"ID"`
			/// - `"Id"` → `"Id"`
			/// - `"id"` → `"id"`
			///
			/// - Warning: Overrides camel case mode  when the first token is acronym
			///
			/// Examples:
			/// - `"someString"` → `"someString"`
			/// - `"uuidString"` → `"uuidString"`
			/// - `"UuidString"` → `"UuidString"`
			/// - `"UUIDString"` → `"UUIDString"`
			case preserve

			/// Always uppercase or lowercase acronyms
			///
			/// **Standard processing policy**
			///
			/// Examples:
			/// - `"ID"` → `"ID"`, or `"id"` if first token in camel case
			/// - `"Id"` → `"ID"`, or `"id"` if first token in camel case
			/// - `"id"` → `"ID"`, or `"id"` if first token in camel case
			case alwaysMatchCase = "always-match-case"

			/// Always capitalize acronyms
			///
			/// Examples:
			/// - `"ID"` → `"Id"`
			/// - `"Id"` → `"Id"`
			/// - `"id"` → `"Id"`
			///
			/// - Warning: Overrides `Mode.camel` when the first token is acronym
			///
			/// Examples:
			/// - `"someString"` → `"someString"`
			/// - `"uuidString"` → `"UuidString"`
			case alwaysCapitalize = "always-capitalize"

			/// Always capitalize acronyms
			///
			/// First token behaves like `.alwaysMatchCase`, rest tokens are processed like `.alwaysCapitalize`
			///
			/// Examples:
			/// - `"ID"` → `"Id"`, or `"id"` if first token in camel case
			/// - `"Id"` → `"Id"`, or `"id"` if first token in camel case
			/// - `"id"` → `"Id"`, or `"id"` if first token in camel case
			case conditionalCapitalization = "conditional-capitalization"

			public init(
				_ mode: ProcessingPolicy.RawValue
			) {
				self = switch mode {
				case .preserve: .preserve
				case .alwaysMatchCase: .alwaysMatchCase
				case .alwaysCapitalize: .alwaysCapitalize
				case .conditionalCapitalization: .conditionalCapitalization
				}
			}

			public var aliasedValue: ProcessingPolicy.RawValue {
				switch self {
				case .default: .default
				case .current: .current
				case .preserve: .preserve
				case .alwaysMatchCase: .alwaysMatchCase
				case .alwaysCapitalize: .alwaysCapitalize
				case .conditionalCapitalization: .conditionalCapitalization
				}
			}
		}

		case alias(Alias)

		/// Creates a new instance of this type from a string representation.
		public init?(_ description: String) {
			if let alias = Alias(rawValue: description.case(.kebab)) {
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
				throw _Error("Got unexpected value \"\(description)\" for acronyms.processing-policy")
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			if Manifest.Version.current.major == 1 || !Manifest.encodeAliases {
				try container.encode(Alias(self.rawValue).rawValue)
			} else {
				try container.encode(description)
			}
		}
	}
}

extension Manifest.AcronymsConfig.ProcessingPolicy: ExpressibleByArgument {
	/// Creates a new instance of this type from a command-line-specified argument.
	public init?(argument: String) {
		self.init(argument)
	}

	/// The description of this instance to show as a default value in a
	/// command-line tool's help screen.
	public var defaultValueDescription: String {
		"Default value is \"always-match-case\"."
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
			Alias.default.rawValue: "Default value. Equivalent to \"always-match-case\".",
			Alias.current.rawValue: "Equivalent to default value.",
			Alias.preserve.rawValue: "Preserves the original formatting for acronyms.",
			Alias.alwaysMatchCase.rawValue: "Always matches case for each character",
			Alias.alwaysCapitalize.rawValue: "Always capitalizes the first character of acronyms, while keeping the rest lowercase, regardless of the position of the acronym in the text",
			Alias.conditionalCapitalization.rawValue: "Capitalizes the first character of acronyms only when they are NOT the first token in given identifier"
		]
	}
}

