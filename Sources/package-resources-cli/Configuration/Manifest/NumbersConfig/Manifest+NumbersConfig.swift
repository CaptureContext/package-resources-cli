import ArgumentParser
import Casification
import CasePaths

extension Manifest {
	public struct NumbersConfig: Codable, Sendable {
		public static var current: Self { .init() }
		public static let `default`: Self = .init(
			separator: .default,
			nextTokenMode: .default,
			allowedDelimeters: .default,
			singleLetterBoundaryOptions: .default
		)

		public var separator: Separator
		public var nextTokenMode: NextTokenMode
		public var allowedDelimeters: AllowedDelimters
		public var singleLetterBoundaryOptions: SingleLetterBoundaryOptions

		public init(
			separator: Separator = .current,
			nextTokenMode: NextTokenMode = .current,
			allowedDelimeters: AllowedDelimters = .current,
			singleLetterBoundaryOptions: SingleLetterBoundaryOptions = .current
		) {
			self.separator = separator
			self.nextTokenMode = nextTokenMode
			self.allowedDelimeters = allowedDelimeters
			self.singleLetterBoundaryOptions = singleLetterBoundaryOptions
		}

		public init(from decoder: any Decoder) throws {
			self = try decoder.decode { container in
				try NumbersConfig(
					separator: container.decodeIfPresent("separator").or(.current),
					nextTokenMode: container.decodeIfPresent("next-token-mode").or(.current),
					allowedDelimeters: container.decodeIfPresent("allowed-delimeters").or(.current),
					singleLetterBoundaryOptions: container.decodeIfPresent("single-letter-boundary-options").or(.current)
				)
			}
		}

		public func encode(to encoder: any Encoder) throws {
			try encoder.encode { container in
				try container.encode(separator, forKey: "separator")
				try container.encode(nextTokenMode, forKey: "next-token-mode")
				try container.encode(allowedDelimeters, forKey: "allowed-delimeters")
				try container.encode(singleLetterBoundaryOptions, forKey: "single-letter-boundary-options")
			}
		}
	}
}
