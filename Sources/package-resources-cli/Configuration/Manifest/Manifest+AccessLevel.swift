import ArgumentParser
import CasePaths
import PackageResourcesClient

extension Manifest {
	@CasePathable
	public enum AccessLevelConfig: Codable, Equatable, Sendable, LosslessStringConvertible {

		case none
		case `default`
		case value(AccessLevel)

		public init?(_ description: String) {
			if description == "none" {
				self = .none
			} else if let accessLevel = AccessLevel(rawValue: description) {
				self = .value(accessLevel)
			} else {
				return nil
			}
		}

		public var description: String {
			switch self {
			case .none:
				"none"
			case .default:
				"default"
			case let .value(accessLevel):
				accessLevel.rawValue
			}
		}

		public var rawValue: AccessLevel? {
			switch self {
			case .none:
				nil
			case .default:
				.internal
			case let .value(accessLevel):
				accessLevel
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			let description = try container.decode(String.self)
			if let value = Self(description) {
				self = value
			} else {
				throw _Error("Got unexpected value \"\(description)\" for access-level")
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode(description)
		}
	}
}

extension Manifest.AccessLevelConfig: ExpressibleByArgument {
	public init?(argument: String) {
		self.init(argument)
	}

	public var defaultValueDescription: String {
		"internal"
	}

	public static var allValueStrings: [String] {
		[
			AccessLevel.private.rawValue,
			AccessLevel.internal.rawValue,
			AccessLevel.package.rawValue,
			AccessLevel.public.rawValue,
			"default",
			"none",
		]
	}
}
