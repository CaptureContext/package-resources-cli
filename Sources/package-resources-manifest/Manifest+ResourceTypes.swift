import ArgumentParser
import PackageResourcesClient

extension Manifest {
	public enum ResourceType: String, CaseIterable, Codable, Sendable, LosslessStringConvertible {
		case all
		case colors
		case fonts
		case images
		case nibs
		case scnScenes = "scn-scenes"
		case storyboards
		case xcStrings = "xc-strings"
		case interfaceBuilder = "interface-builder"
		case none

		// Equivalent to `all`
		case `default` = "default"
		case `__not_set__` = "__not_set__"

		public init?(_ description: String) {
			self.init(rawValue: description)
		}

		public var description: String {
			rawValue
		}

		public var enabledResourceTypes: EnabledResourceTypes {
			switch self {
			case .__not_set__:
				Self.default.enabledResourceTypes
			case .all:
				.all
			case .colors:
				.colors
			case .fonts:
				.fonts
			case .images:
				.images
			case .nibs:
				.nibs
			case .scnScenes:
				.scnScenes
			case .storyboards:
				.storyboards
			case .xcStrings:
				.xcStrings
			case .interfaceBuilder:
				.interfaceBuilder
			case .default:
				.all
			case .none:
				[]
			}
		}
	}

	public struct ResourceTypes: Codable, Equatable, Sendable, RawRepresentable {
		public typealias RawValue = [ResourceType]

		public static var `default`: Self {
			.init(rawValue: [.default])
		}

		public var rawValue: RawValue

		public var enabledResourceTypes: EnabledResourceTypes {
			rawValue.reduce([]) { $0.union($1.enabledResourceTypes) }
		}

		public init(rawValue: RawValue) {
			self.rawValue = rawValue.isEmpty ? Self.default.rawValue : rawValue
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			do {
				self.init(rawValue: try container.decode(RawValue.self))
			} catch {
				let decodingError = error
				do {
					self.init(rawValue: [try container.decode(ResourceType.self)])
				} catch {
					throw decodingError
				}
			}
		}

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			try container.encode(rawValue)
		}
	}
}

extension Manifest.ResourceType: ExpressibleByArgument {
	public init?(argument: String) {
		self.init(argument)
	}

	public var defaultValueDescription: String {
		"all"
	}

	public static var allValueStrings: [String] {
		allCases.map(\.rawValue)
	}
}
