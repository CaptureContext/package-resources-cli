import ArgumentParser
import Foundation
import Dependencies
import PackageResourcesClient
import PackageResourcesManifest
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
			help: "Compatibility override for xcstrings.group-by-catalog"
		)
		public var groupXCStringsByCatalogName: Bool?

		@Flag(
			name: .customLong("group-by-catalog"),
			inversion: .prefixedNo,
			help: "Groups catalog-backed resources by catalog folders"
		)
		public var groupByCatalogName: Bool?

		@Flag(
			name: .customLong("xcstrings-split-by-key-path"),
			inversion: .prefixedNo,
			help: "Splits dotted xcstrings keys into nested enums"
		)
		public var xcStringsSplitByKeyPath: Bool?

		@Flag(
			name: .customLong("colors-group-by-folders"),
			inversion: .prefixedNo,
			help: "Groups colors by folders inside an xcassets catalog"
		)
		public var colorsGroupByFolders: Bool?

		@Flag(
			name: .customLong("images-group-by-folders"),
			inversion: .prefixedNo,
			help: "Groups images by folders inside an xcassets catalog"
		)
		public var imagesGroupByFolders: Bool?

		@Flag(
			name: .customLong("scn-scenes-group-by-folders"),
			inversion: .prefixedNo,
			help: "Groups scenes by folders inside an scnassets catalog"
		)
		public var scnScenesGroupByFolders: Bool?

		@Flag(
			name: .customLong("colors-split-by-key-path"),
			inversion: .prefixedNo,
			help: "Splits dotted color asset names and path components into nested enums"
		)
		public var colorsSplitByKeyPath: Bool?

		@Flag(
			name: .customLong("images-split-by-key-path"),
			inversion: .prefixedNo,
			help: "Splits dotted image asset names and path components into nested enums"
		)
		public var imagesSplitByKeyPath: Bool?

		@Flag(
			name: .customLong("scn-scenes-split-by-key-path"),
			inversion: .prefixedNo,
			help: "Splits dotted scene names and path components into nested enums"
		)
		public var scnScenesSplitByKeyPath: Bool?

		@Flag(name: .customLong("ignore-colors"), inversion: .prefixedNo)
		public var ignoreColors: Bool?

		@Flag(name: .customLong("ignore-images"), inversion: .prefixedNo)
		public var ignoreImages: Bool?

		@Flag(name: .customLong("ignore-fonts"), inversion: .prefixedNo)
		public var ignoreFonts: Bool?

		@Flag(name: .customLong("ignore-nibs"), inversion: .prefixedNo)
		public var ignoreNibs: Bool?

		@Flag(name: .customLong("ignore-scn-scenes"), inversion: .prefixedNo)
		public var ignoreSCNScenes: Bool?

		@Flag(name: .customLong("ignore-storyboards"), inversion: .prefixedNo)
		public var ignoreStoryboards: Bool?

		@Flag(name: .customLong("ignore-xcstrings"), inversion: .prefixedNo)
		public var ignoreXCStrings: Bool?

		@Option(
			name: .customLong("resource-types"),
			help: "Legacy resource selection for v1-v3 manifests. Superseded by ignore flags in v4."
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
			var config = (try? self.config.flatMap(Manifest.load(at:)))
				.or(Manifest())
				.ifLet(output, override: \.output)
				.ifLet(indentor, override: \.indentor)
				.ifLet(indentSize, override: \.indentSize)
				.ifLet(accessLevel, override: \.accessLevel)
				.ifLet(
					groupByCatalogName,
					override: \.groupByCatalogName
				)
				.ifLet(
					groupXCStringsByCatalogName,
					override: \.groupXCStringsByCatalogName
				)
				.ifLet(
					xcStringsSplitByKeyPath,
					override: \.xcStringsSplitByKeyPath
				)
				.ifLet(
					colorsGroupByFolders,
					override: \.colorsGroupByFolders
				)
				.ifLet(
					imagesGroupByFolders,
					override: \.imagesGroupByFolders
				)
				.ifLet(
					scnScenesGroupByFolders,
					override: \.scnScenesGroupByFolders
				)
				.ifLet(
					colorsSplitByKeyPath,
					override: \.colorsSplitByKeyPath
				)
				.ifLet(
					imagesSplitByKeyPath,
					override: \.imagesSplitByKeyPath
				)
				.ifLet(
					scnScenesSplitByKeyPath,
					override: \.scnScenesSplitByKeyPath
				)
				.ifLet(ignoreColors, override: \.ignoreColors)
				.ifLet(ignoreImages, override: \.ignoreImages)
				.ifLet(ignoreFonts, override: \.ignoreFonts)
				.ifLet(ignoreNibs, override: \.ignoreNibs)
				.ifLet(ignoreSCNScenes, override: \.ignoreSCNScenes)
				.ifLet(ignoreStoryboards, override: \.ignoreStoryboards)
				.ifLet(ignoreXCStrings, override: \.ignoreXCStrings)
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

			if config.version.major < 4 {
				config.ifLet(resourceTypesOverride, set: \.resourceTypes)
			} else if resourceTypesOverride != nil {
				print(
					ANSI("⚠️ --resource-types is ignored for manifest v4; use --ignore-* flags instead.")
						.foreground(.yellow)
						.bold()
				)
			}

			let outputPath = output ?? config.output ?? input.appending("/Resources.generated.swift")

			try await withDependencies {
				$0.resourceFormatConfig = config.format.resourceFormatConfig
			} operation: {
				@Dependency(\.packageResourcesClient)
				var client

				try await client.processResources(
					for: config.enabledResourceTypes,
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
