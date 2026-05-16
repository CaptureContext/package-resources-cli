import ArgumentParser
import Casification
import CasePaths

extension Manifest {
	public struct NumbersConfig: Codable, Equatable, Sendable {
		public static var current: Self { .init() }
		public static let `default`: Self = .init(
			separator: .default,
			nextTokenMode: .default,
			allowedDelimeters: .default,
			endingNumberBoundaryOptions: .default,
			singleLetterBoundaryOptions: .default
		)

		public var separator: Separator
		public var nextTokenMode: NextTokenMode
		public var allowedDelimeters: AllowedDelimters
		public var endingNumberBoundaryOptions: BoundaryOptions
		public var singleLetterBoundaryOptions: BoundaryOptions

		public init(
			separator: Separator = .current,
			nextTokenMode: NextTokenMode = .current,
			allowedDelimeters: AllowedDelimters = .current,
			endingNumberBoundaryOptions: BoundaryOptions = .current,
			singleLetterBoundaryOptions: BoundaryOptions = .current
		) {
			self.separator = separator
			self.nextTokenMode = nextTokenMode
			self.allowedDelimeters = allowedDelimeters
			self.endingNumberBoundaryOptions = endingNumberBoundaryOptions
			self.singleLetterBoundaryOptions = singleLetterBoundaryOptions
		}

		public init(from decoder: any Decoder) throws {
			self = try decoder.decode { container in
				try NumbersConfig(
					separator: container.decodeIfPresent("separator").or(.current),
					nextTokenMode: container.decodeIfPresent("next-token-mode").or(.current),
					allowedDelimeters: container.decodeIfPresent("allowed-delimeters").or(.current),
					endingNumberBoundaryOptions: container.decodeIfPresent("ending-number-boundary-options").or(.current),
					singleLetterBoundaryOptions: container.decodeIfPresent("single-letter-boundary-options").or(.current)
				)
			}
		}

		public func encode(to encoder: any Encoder) throws {
			try encoder.encode { container in
				try container.encode(separator, forKey: "separator")
				try container.encode(nextTokenMode, forKey: "next-token-mode")
				try container.encode(allowedDelimeters, forKey: "allowed-delimeters")
				try encodeBoundaryOption(
					endingNumberBoundaryOptions,
					id: "ending_number",
					using: &container,
					for: "ending-number-boundary-options"
				)
				try encodeBoundaryOption(
					singleLetterBoundaryOptions,
					id: "single_letter",
					using: &container,
					for: "single-letter-boundary-options"
				)
			}
		}

		public var aliasedEndingNumberNumericBoundaryOptions:
		String.Casification.Configuration.NumericBoundaryOptions {
			endingNumberBoundaryOptions.rawValue.reduce([]) {
				switch $1 {
				case let .alias(alias): $0.union(alias.aliasedValue(for: "ending_number"))
				}
			}
		}

		public var aliasedSingleLetterNumericBoundaryOptions:
		String.Casification.Configuration.NumericBoundaryOptions {
			singleLetterBoundaryOptions.rawValue.reduce([]) {
				switch $1 {
				case let .alias(alias): $0.union(alias.aliasedValue(for: "single_letter"))
				}
			}
		}

		public var aliasedNumericBoundaryOptions
		: Set<String.Casification.Configuration.Common.Numbers.BoundaryOption> {
			[
				.endingNumber(aliasedEndingNumberNumericBoundaryOptions),
				.singleLetter(aliasedSingleLetterNumericBoundaryOptions)
			]
		}

		private func encodeBoundaryOption(
			_ options: BoundaryOptions,
			id: String,
			using container: inout KeyedEncodingContainer<RawCodingKey>,
			for key: RawCodingKey
		) throws {
			let numericBoundaryOptions:
			String.Casification.Configuration.NumericBoundaryOptions =
			switch id {
			case "ending_number":
				aliasedEndingNumberNumericBoundaryOptions
			case "single_letter":
				aliasedSingleLetterNumericBoundaryOptions
			default:
				[]
			}

			if Manifest.encodeAliases, Manifest.Version.current.major > 1 {
				let options = Set(options.rawValue.map(\.description)).sorted()
				if options.count == 1, let option = options.first {
					try container.encode(option, forKey: key)
				} else if
					numericBoundaryOptions.contains([
						.disableSeparators,
						.disableTokenProcessing
					])
				{
					try container.encode("current", forKey: key)
				} else {
					try container.encode(options, forKey: key)
				}
			} else {
				var options: BoundaryOptions.RawValue = []

				if numericBoundaryOptions.contains(.disableSeparators) {
					options.append(.disableSeparators)
				}

				if numericBoundaryOptions.contains(.disableTokenProcessing) {
					options.append(.disableTokenProcessing)
				}

				let encodableOptions = Set(options.map(\.description)).sorted()

				if encodableOptions.count == 1, let option = encodableOptions.first {
					try container.encode(option, forKey: key)
				} else {
					try container.encode(encodableOptions, forKey: key)
				}
			}
		}
	}
}
