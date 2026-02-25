import ArgumentParser
import CasePaths
import Casification

extension Manifest.NumbersConfig {
	@CasePathable
	public enum SingleLetterBoundaryOption: RawRepresentable, Codable, Equatable, Sendable, LosslessStringConvertible {
		public static var `default`: Self { .alias(.default) }
		public static var current: Self { .alias(.current) }
		public static var none: Self { .alias(.none) }
		public static var disableSeparators: Self { .alias(.disableSeparators) }
		public static var disableNextTokenProcessing: Self { .alias(.disableNextTokenProcessing) }

		@CasePathable
		public enum Alias: String, CaseIterable, Sendable {
			case `default` = "default"
			case current
			case none
			case disableSeparators = "disable-separators"
			case disableNextTokenProcessing = "disable-next-token-processing"

			public var aliasedValue: String.Casification.Configuration.NumericBoundaryOptions {
				switch self {
				case .default: String.Casification
						.Configuration.Common
						.Numbers.default.boundaryOptions.reduce([]) { $0.union($1.options) }
				case .current: String.Casification
						.Configuration.Common
						.Numbers.current.boundaryOptions.reduce([]) { $0.union($1.options) }
				case .none: []
				case .disableSeparators: .disableSeparators
				case .disableNextTokenProcessing: .disableNextTokenProcessing
				}
			}
		}

		case alias(Alias)

		public init?(_ description: String) {
			if let alias = Alias(rawValue: description.case(.kebab)) {
				self = .alias(alias)
			} else {
				return nil
			}
		}

		public var description: String {
			switch self {
			case let .alias(alias): alias.rawValue
			}
		}

		public init?(rawValue: String) {
			self.init(rawValue)
		}

		public var rawValue: String {
			description
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			let description = try container.decode(String.self)
			if let alias = Self.init(description) {
				self = alias
			} else {
				throw _Error("Unexpected value \(description) for single-letter-boundary-options")
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode(description)
		}
	}

	public struct SingleLetterBoundaryOptions: RawRepresentable, Codable, Equatable, Sendable {
		public typealias RawValue = [SingleLetterBoundaryOption]

		public static var `default`: Self { .init(rawValue: [.default]) }
		public static var current: Self { .init(rawValue: [.current]) }
		public static var none: Self { .init(rawValue: [.none]) }

		public var rawValue: RawValue

		public var numericBoundaryOptions: String.Casification.Configuration.NumericBoundaryOptions {
			rawValue.reduce([]) {
				switch $1 {
				case let .alias(alias): $0.union(alias.aliasedValue)
				}
			}
		}

		public var options: Set<String.Casification.Configuration.Common.Numbers.BoundaryOption> {
			[.singleLetter(numericBoundaryOptions)]
		}

		/// Creates a new instance of this type from a characters set representation
		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			do {
				let options = try container.decode([SingleLetterBoundaryOption].self)
				self.init(rawValue: options)
			} catch {
				let e = error
				do {
					let option = try container.decode(SingleLetterBoundaryOption.self)
					self.init(rawValue: [option])
				} catch {
					throw e
				}
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			if Manifest.encodeAliases, Manifest.Version.current.major > 1 {
				let options = Set(rawValue.map(\.description)).sorted()
				if options.count == 1, let option = options.first {
					try container.encode(option)
				} else if
					numericBoundaryOptions.contains([
						.disableSeparators,
						.disableNextTokenProcessing
					])
				{
					try container.encode("current")
				} else {
					try container.encode(options)
				}
			} else {
				var options: RawValue = []

				if numericBoundaryOptions.contains(.disableSeparators) {
					options.append(.disableSeparators)
				}

				if numericBoundaryOptions.contains(.disableNextTokenProcessing) {
					options.append(.disableNextTokenProcessing)
				}

				let encodableOptions = Set(options.map(\.description)).sorted()

				if encodableOptions.count == 1, let option = encodableOptions.first {
					try container.encode(option)
				} else {
					try container.encode(encodableOptions)
				}
			}
		}
	}
}

extension Manifest.NumbersConfig.SingleLetterBoundaryOption: ExpressibleByArgument {
	/// Creates a new instance of this type from a command-line-specified argument.
	public init?(argument: String) {
		self.init(argument)
	}

	/// The description of this instance to show as a default value in a
	/// command-line tool's help screen.
	public var defaultValueDescription: String {
		"All options are available by default"
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
			Alias.default.rawValue: "Equivalent to all options enabled",
			Alias.current.rawValue: "Equivalent to default value.",
			Alias.none.rawValue: "Disables options. Note that this option has the lowest priority.",
			Alias.disableSeparators.rawValue: "Disables separators for single letter boundaries near numbers",
			Alias.disableNextTokenProcessing.rawValue: "Disables next token formatting for single letter for single letter boundaries near numbers",
		]
	}
}
