import ArgumentParser
import CasePaths
import Casification
import IssueReporting

extension Manifest.NumbersConfig {
	@CasePathable
	public enum BoundaryOption: RawRepresentable, Codable, Equatable, Sendable, LosslessStringConvertible {
		public static var `default`: Self { .alias(.default) }
		public static var current: Self { .alias(.current) }
		public static var none: Self { .alias(.none) }
		public static var disableSeparators: Self { .alias(.disableSeparators) }
		public static var disableTokenProcessing: Self { .alias(.disableTokenProcessing) }

		@CasePathable
		public enum Alias: String, CaseIterable, Sendable {
			case `default` = "default"
			case current
			case none
			case disableSeparators = "disable-separators"
			case disableTokenProcessing = "disable-token-processing"

			public func aliasedValue(
				for id: String
			) -> String.Casification.Configuration.NumericBoundaryOptions {
				switch self {
				case .default: String.Casification
						.Configuration.Common
						.Numbers.default.boundaryOptions
						.filter { $0.id.__packageResourcesEqual(to: id) }
						.reduce([]) { $0.union($1.options) }
				case .current: String.Casification
						.Configuration.Common
						.Numbers.current.boundaryOptions
						.filter { $0.id.__packageResourcesEqual(to: id) }
						.reduce([]) { $0.union($1.options) }
				case .none: []
				case .disableSeparators: .disableSeparators
				case .disableTokenProcessing: .disableTokenProcessing
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

			if Manifest.Version.current.major > 1, description == "disable-next-token-processing" {
				if Manifest.Version.current.major > 2 {
					reportIssue("`disable-next-token-processing` was renamed to `disable-token-processing`")
				}
				self = .alias(.disableTokenProcessing)
				return
			}

			if let alias = Self.init(description) {
				self = alias
			} else {
				throw _Error("Unexpected value \(description) for boundary options")
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode(description)
		}
	}

	public struct BoundaryOptions: RawRepresentable, Codable, Equatable, Sendable {
		public typealias RawValue = [BoundaryOption]

		public static var `default`: Self { .init(rawValue: [.default]) }
		public static var current: Self { .init(rawValue: [.current]) }
		public static var none: Self { .init(rawValue: [.none]) }

		public var rawValue: RawValue

		/// Creates a new instance of this type from a characters set representation
		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			do {
				let options = try container.decode([BoundaryOption].self)
				self.init(rawValue: options)
			} catch {
				let e = error
				do {
					let option = try container.decode(BoundaryOption.self)
					self.init(rawValue: [option])
				} catch {
					throw e
				}
			}
		}
	}
}

extension Manifest.NumbersConfig.BoundaryOption: ExpressibleByArgument {
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
			Alias.disableTokenProcessing.rawValue: "Disables next token formatting for single letter for single letter boundaries near numbers",
		]
	}
}

private extension Equatable {
	func __packageResourcesEqual(to other: any Equatable) -> Bool {
		guard let other = other as? Self else { return false }
		return self == other
	}
}
