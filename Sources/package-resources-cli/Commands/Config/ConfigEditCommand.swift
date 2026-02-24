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
		public var indentor: String? = nil

		@Option(
			name: .customLong("indent-size"),
			help: "Indent size"
		)
		public var indentSize: Int? = nil

		@Option(
			name: .customLong("numbers-next-token-mode"),
			help: "Processsing mode for a token after a number"
		)
		public var numbersNextTokenMode: String? = nil

		@Option(
			name: .customLong("numbers-separator"),
			help: "Separator for numbers"
		)
		public var numbersSeparator: String? = nil

		@Option(
			name: .customLong("numbers-allowed-delimeters"),
			help: "Allowed delimeters for numbers"
		)
		public var numbersAllowedDelimeters: String? = nil

		@Option(
			name: .customLong("numbers-single-letter-boundary-options"),
			help: "Processsing mode for a token after a number"
		)
		public var numbersSingleLetterBoundaryOptions: [String] = [._unspecified]

		@Option(name: .customLong(
			"acronyms-processing"),
			help: "Acronyms processing"
		)
		public var acronymsProcessing: String? = nil

		@Option(
			name: .long,
			help: "Acronyms to be treated as a single character in camelCasing"
		)
		public var acronymsValues: [String] = [._unspecified]

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
			name: .customLong("remove-numbers-next-token-mode"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.next-token-mode from the config file"
		)
		var removeNumbersNextTokenMode: Bool = false

		@Flag(
			name: .customLong("remove-acronyms-processing"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.separator from the config file"
		)
		var removeNumbersSeparator: Bool = false

		@Flag(
			name: .customLong("remove-numbers-allowed-delimeters"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.allowed-delimeters from the config file"
		)
		var removeNumbersAllowedDelimeters: Bool = false

		@Flag(
			name: .customLong("remove-numbers-single-letter-boundary-options"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes numbers.single-letter-boundary-options from the config file"
		)
		var removeNumbersSingleLetterBoundaryOptions: Bool = false

		@Flag(
			name: .customLong("remove-acronyms-processing"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes acronyms.processing-policy from the config file"
		)
		var removeAcronymsProcessing: Bool = false

		@Flag(
			name: .customLong("remove-acronyms-values"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes acronyms.values from the config file"
		)
		var removeAcronymsValues: Bool = false

		func run() throws {
			let configFile = try File(path: parent.path)

			var (config, format) = Manifest.loadWithFormat(at: parent.path) ?? (.init(), .yaml)

			do {
				config = config
					.ifLet(output, override: \.output)
					.ifLet(indentor, override: \.indentor)
					.ifLet(indentSize, override: \.indentSize)
					.ifLet(
						numbersNextTokenMode.flatMap { .init(_config: $0) },
						override: \.camelCaseNumbers.nextTokenMode
					)
					.ifLet(
						numbersSeparator.map { $0[...] },
						override: \.camelCaseNumbers.separator
					)
					.ifLet(
						numbersAllowedDelimeters.map { Set($0) },
						override: \.commonNumbers.allowedDelimeters
					)
					.ifLet(
						numbersSingleLetterBoundaryOptions == [._unspecified] ? nil : [
							.singleLetter(.init(_config: numbersSingleLetterBoundaryOptions))
						],
						override: \.commonNumbers.boundaryOptions
					)
					.ifLet(
						acronymsProcessing.flatMap { .init(_config: $0) },
						override: \.camelCaseAcronyms.processingPolicy
					)
					.ifLet(
						acronymsValues == [._unspecified] ? nil : Set(acronymsValues.map { $0[...] }),
						override: \.commonAcronyms
					)
			}

			let ignoredKeys: Set<[RawCodingKey]> = reduce([]) { ignoredKeys in
				if removeOutput { ignoredKeys.insert(["output"]) }
				if removeIndentor { ignoredKeys.insert(["indentor"]) }
				if removeIndentSize { ignoredKeys.insert(["indent-size"]) }
				if removeNumbersNextTokenMode { ignoredKeys.insert(["numbers", "separator"]) }
				if removeNumbersAllowedDelimeters { ignoredKeys.insert(["numbers", "allowed-delimeters"]) }
				if removeNumbersSingleLetterBoundaryOptions { ignoredKeys.insert(["numbers", "single-letter-boundary-options"]) }
				if removeNumbersSeparator { ignoredKeys.insert(["numbers", "next-token-mode"]) }
				if removeAcronymsProcessing { ignoredKeys.insert(["acronyms", "processing-policy"]) }
				if removeAcronymsValues { ignoredKeys.insert(["acronyms", "values"]) }
			}

			let encodeJSON: () throws -> Void = {
				try configFile.write(JSONEncoder().encode(config))
			}

			let encodeYAML: () throws -> Void = {
				try configFile.write(YAMLEncoder().encode(config))
			}

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


			print(
				 ANSI("✅ Successfully updated \(configFile.name) file")
					 .foreground(.green)
					 .bold()
			 )
		}
	}
}

