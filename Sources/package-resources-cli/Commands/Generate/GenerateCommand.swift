import ArgumentParser
import Foundation
import Casification
import Dependencies
import PackageResourcesClient
import Yams

extension App {
	struct GenerateCommand: AsyncParsableCommand {
		static let configuration: CommandConfiguration = .init(
			commandName: "generate",
			abstract: "Generates boilerplate for package resources"
		)

		@Option(
			name: .shortAndLong, help: "Path to root directory for scanning.",
			transform: { $0 }
		)
		public var input: String = "./"

		@Option(
			name: .shortAndLong,
			help: "Path to configuration file"
		)
		public var config: String? = nil

		@Option(
			name: .shortAndLong,
			help: "Path to output file"
		)
		public var output: String? = nil

		@Option(
			name: .long,
			help: "Indentation character"
		)
		public var indentor: Manifest.Indentor? = nil

		@Option(
			name: .customLong("indent-size"),
			help: "Number of indentors per indentation level"
		)
		public var indentSize: Manifest.IndentSize? = nil

		@Option(
			name: .customLong("access-level"),
			help: "Access level for generated declarations"
		)
		public var accessLevel: Manifest.AccessLevelConfig? = nil

		@Flag(
			name: .customLong("group-xcstrings-by-catalog-name"),
			inversion: .prefixedNo,
			help: "Groups xcstrings accessors under a catalog-name enum"
		)
		public var groupXCStringsByCatalogName: Bool?

		@Option(
			name: .customLong("resource-types"),
			help: "Resource types to generate"
		)
		public var resourceTypes: [Manifest.ResourceType] = [.__not_set__]

		@Option(
			name: .customLong("numbers-separator"),
			help: "Separator for numbers"
		)
		public var numbersSeparator: Manifest.NumbersConfig.Separator? = nil

		@Option(
			name: .customLong("numbers-next-token-mode"),
			help: "Processsing mode for a token after a number"
		)
		public var numbersNextTokenMode: Manifest.NumbersConfig.NextTokenMode? = nil

		@Option(
			name: .customLong("numbers-allowed-delimeters"),
			help: "Allowed delimeters for numbers"
		)
		public var numbersAllowedDelimeters: Manifest.NumbersConfig.AllowedDelimters? = nil

		@Option(
			name: .customLong("numbers-ending-number-boundary-options"),
			help: "Boundary options for ending number tokens"
		)
		public var numbersEndingNumberBoundaryOptions: [Manifest.NumbersConfig.BoundaryOption] = []

		@Option(
			name: .customLong("numbers-single-letter-boundary-options"),
			help: "Boundary options for single-letter tokens near numbers"
		)
		public var numbersSingleLetterBoundaryOptions: [Manifest.NumbersConfig.BoundaryOption] = []

		@Option(name: .customLong(
			"acronyms-processing-policy"),
			help: "Acronyms processing"
		)
		public var acronymsProcessingPolicy: Manifest.AcronymsConfig.ProcessingPolicy = .current

		@Option(
			name: .customLong("acronyms-values"),
			help: "Acronyms to be treated as a single character in camelCasing"
		)
		public var acronymsValues: [String] = ["current"]

		public func run() async throws {
			let config = (try? self.config.flatMap(Manifest.load(at:)))
				.or(Manifest())
				.ifLet(output, override: \.output)
				.ifLet(indentor, override: \.indentor)
				.ifLet(indentSize, override: \.indentSize)
				.ifLet(accessLevel, override: \.accessLevel)
				.ifLet(
					groupXCStringsByCatalogName,
					override: \.groupXCStringsByCatalogName
				)
				.ifLet(
					resourceTypesOverride,
					override: \.resourceTypes
				)
				.ifLet(
					numbersSeparator,
					override: \.numbers.separator
				)
				.ifLet(
					numbersNextTokenMode,
					override: \.numbers.nextTokenMode
				)
				.ifLet(
					numbersAllowedDelimeters,
					override: \.numbers.allowedDelimeters
				)
				.ifLet(
					numbersEndingNumberBoundaryOptionsOverride,
					override: \.numbers.endingNumberBoundaryOptions
				)
				.ifLet(
					numbersSingleLetterBoundaryOptionsOverride,
					override: \.numbers.singleLetterBoundaryOptions
				)
				.ifLet(
					acronymsProcessingPolicy,
					override: \.acronyms.processingPolicy
				)
				.ifLet(
					acronymsValues,
					override: \.acronyms.values
				)

			let outputPath = output ?? config.output ?? input.appending("/Resources.generated.swift")

			try await withCasification({
				$0.camelCase.acronyms.processingPolicy = config.acronyms.processingPolicy.rawValue
				$0.camelCase.numbers.separator = config.numbers.separator.rawValue
				$0.camelCase.numbers.nextTokenMode = config.numbers.nextTokenMode.rawValue
				$0.common.numbers.allowedDelimeters = config.numbers.allowedDelimeters.rawValue
				$0.common.numbers.boundaryOptions = config.numbers.aliasedNumericBoundaryOptions
				$0.acronyms = config.acronyms.resolvedValues
			}) {
				try await withDependencies {
					$0.formatClient = .standard(
						indentor: config.indentor.rawValue,
						indentSize: config.indentSize.rawValue,
						accessLevel: config.accessLevel.rawValue,
						groupXCStringsByCatalogName: config.groupXCStringsByCatalogName
					)
				} operation: {
					@Dependency(\.packageResourcesClient)
					var client

					try await client.processResources(
						for: config.resourceTypes.enabledResourceTypes,
						atPath: input,
						into: outputPath
					)
				}

				print(
					ANSI("✅ Successfully generated package resources")
						.foreground(.green)
						.bold()
				)
			}
		}

		private var resourceTypesOverride: Manifest.ResourceTypes? {
			resourceTypes == [.__not_set__] ? nil : .init(rawValue: resourceTypes)
		}

		private var numbersEndingNumberBoundaryOptionsOverride: Manifest.NumbersConfig.BoundaryOptions? {
			numbersEndingNumberBoundaryOptions.isEmpty ? nil : .init(rawValue: numbersEndingNumberBoundaryOptions)
		}

		private var numbersSingleLetterBoundaryOptionsOverride: Manifest.NumbersConfig.BoundaryOptions? {
			numbersSingleLetterBoundaryOptions.isEmpty ? nil : .init(rawValue: numbersSingleLetterBoundaryOptions)
		}
	}
}
