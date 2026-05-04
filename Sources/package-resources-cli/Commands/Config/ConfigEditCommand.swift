import ArgumentParser
import Foundation
import PackageResourcesFS
import Yams

extension App.ConfigCommand {
	struct EditCommand: ParsableCommand {
		enum Format: String, Codable, CaseIterable, ExpressibleByArgument {
			case yaml
			case json
			case keep
		}

		static let configuration: CommandConfiguration = .init(
			commandName: "edit",
			abstract: "Overwrites configuration file entries",
			subcommands: []
		)

		@ParentCommand
		var parent: App.ConfigCommand

		@Option(
			name: .shortAndLong,
			help: "Format override"
		)
		var format: Format = .keep

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

		@Flag(
			name: .customLong("encode-aliases"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Disables alias resolution for config values"
		)
		var encodeAliases: Bool = false

		@Flag(
			name: .customLong("remove-output"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes output path from the config file"
		)
		var removeOutput: Bool = false

		@Flag(
			name: .customLong("remove-indentor"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes indentor from the config file"
		)
		var removeIndentor: Bool = false

		@Flag(
			name: .customLong("remove-indent-size"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes indent-size from the config file"
		)
		var removeIndentSize: Bool = false

		@Flag(
			name: .customLong("remove-access-level"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes access-level from the config file"
		)
		var removeAccessLevel: Bool = false

		@Flag(
			name: .customLong("remove-group-xcstrings-by-catalog-name"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes group-xcstrings-by-catalog-name from the config file"
		)
		var removeGroupXCStringsByCatalogName: Bool = false

		@Flag(
			name: .customLong("remove-resource-types"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes resource-types from the config file"
		)
		var removeResourceTypes: Bool = false

		@Flag(
			name: .customLong("remove-numbers-separator"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.separator from the config file"
		)
		var removeNumbersSeparator: Bool = false

		@Flag(
			name: .customLong("remove-numbers-next-token-mode"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.next-token-mode from the config file"
		)
		var removeNumbersNextTokenMode: Bool = false

		@Flag(
			name: .customLong("remove-numbers-allowed-delimeters"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.allowed-delimeters from the config file"
		)
		var removeNumbersAllowedDelimeters: Bool = false

		@Flag(
			name: .customLong("remove-numbers-ending-number-boundary-options"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.ending-number-boundary-options from the config file"
		)
		var removeNumbersEndingNumberBoundaryOptions: Bool = false

		@Flag(
			name: .customLong("remove-numbers-single-letter-boundary-options"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.single-letter-boundary-options from the config file"
		)
		var removeNumbersSingleLetterBoundaryOptions: Bool = false

		@Flag(
			name: .customLong("remove-acronyms-processing-policy"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes acronyms.processing-policy from the config file"
		)
		var removeAcronymsProcessingPolicy: Bool = false

		@Flag(
			name: .customLong("remove-acronyms-values"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes acronyms.values from the config file"
		)
		var removeAcronymsValues: Bool = false

		func run() throws {
			let configFile = try File(path: parent.path)

			var (config, format) = (try? Manifest.loadWithFormat(at: parent.path)) ?? (Manifest(), .yaml)

			do {
				config = config
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
			}

			let ignoredKeys: Set<[RawCodingKey]> = reduce([]) { ignoredKeys in
				if removeOutput { ignoredKeys.insert(["output"]) }
				if removeIndentor { ignoredKeys.insert(["indentor"]) }
				if removeIndentSize { ignoredKeys.insert(["indent-size"]) }
				if removeAccessLevel { ignoredKeys.insert(["access-level"]) }
				if removeGroupXCStringsByCatalogName { ignoredKeys.insert(["group-xcstrings-by-catalog-name"]) }
				if removeResourceTypes { ignoredKeys.insert(["resource-types"]) }
				if removeNumbersSeparator { ignoredKeys.insert(["numbers", "separator"]) }
				if removeNumbersAllowedDelimeters { ignoredKeys.insert(["numbers", "allowed-delimeters"]) }
				if removeNumbersEndingNumberBoundaryOptions { ignoredKeys.insert(["numbers", "ending-number-boundary-options"]) }
				if removeNumbersSingleLetterBoundaryOptions { ignoredKeys.insert(["numbers", "single-letter-boundary-options"]) }
				if removeNumbersNextTokenMode { ignoredKeys.insert(["numbers", "next-token-mode"]) }
				if removeAcronymsProcessingPolicy { ignoredKeys.insert(["acronyms", "processing-policy"]) }
				if removeAcronymsValues { ignoredKeys.insert(["acronyms", "values"]) }
			}

			let encodeJSON: () throws -> Void = {
				try configFile.write(JSONEncoder().encode(config))
			}

			let encodeYAML: () throws -> Void = {
				try configFile.write(YAMLEncoder().encode(config))
			}

			try Manifest.$encodeAliases.withValue(encodeAliases) {
				try Manifest.$ignoredKeys.withValue(ignoredKeys) {
					switch self.format {
					case .json: try encodeJSON()
					case .yaml: try encodeYAML()
					case .keep:
						switch format {
						case .json: try encodeJSON()
						case .yaml: try encodeYAML()
						}
					}
				}
			}

			print(
				ANSI("✅ Successfully updated \(configFile.name) file")
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
