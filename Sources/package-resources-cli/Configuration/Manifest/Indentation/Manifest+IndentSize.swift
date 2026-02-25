import ArgumentParser
import CasePaths

extension Manifest {
	@CasePathable
	public enum IndentSize: RawRepresentable, Codable, Equatable, Sendable, LosslessStringConvertible {
		public static var `default`: Self { .alias(.default) }

		@CasePathable
		public enum Alias: String, CaseIterable, Sendable {
			/// Default value is `1`. Though it's dynamically adjusted to `2` when indentor is `" "`
			case `default` = "default"

			public var aliasedValue: IndentSize.RawValue {
				switch self {
				case .default:
					Indentor.current.rawValue == Indentor.whitespace.rawValue ? 2 : 1
				}
			}
		}

		case alias(Alias)
		case value(Int)

		/// Creates a new instance of this type from a string representation.
		public init?(_ description: String) {
			if let alias = Alias(rawValue: description) {
				self = .alias(alias)
			} else if let rawValue = Int(description) {
				self = .value(rawValue)
			} else {
				return nil
			}
		}

		/// A textual representation of this instance.
		public var description: String {
			self[case: \.alias]?.rawValue ?? String(rawValue)
		}

		/// Creates a new instance of this type from a string representation.
		public init(rawValue: Int) {
			self = .value(rawValue)
		}

		/// A textual representation of this instance.
		public var rawValue: Int {
			switch self {
			case let .alias(alias): alias.aliasedValue
			case let .value(value): value
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			do {
				try self.init(rawValue: container.decode(Int.self))
			} catch {
				guard let alias = try IndentSize(container.decode(String.self))
				else { throw error }
				self = alias
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			if Manifest.encodeAliases, Manifest.Version.current.major > 1, let alias = self[case: \.alias] {
				try container.encode(alias.rawValue)
			} else {
				try container.encode(rawValue)
			}
		}
	}
}

extension Manifest.IndentSize: ExpressibleByArgument {
	/// Creates a new instance of this type from a command-line-specified argument.
	public init?(argument: String) {
		self.init(argument)
	}

	/// The description of this instance to show as a default value in a
	/// command-line tool's help screen.
	public var defaultValueDescription: String {
		"Default value is 1. Though it's dynamically adjusted to 2 when indentor is \" \"."
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
			"<int>"
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
			Alias.default.rawValue: "Dynamic adjustment based on indentation symbol",
			"<int>": "Amount of repetitions of indentation symbol per indentation level"
		]
	}
}
