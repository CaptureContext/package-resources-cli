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

		@Option(name: .shortAndLong, help: "Format override")
		var format: Format = .keep

		@Option(name: .shortAndLong, help: "Path to output file")
		public var output: String? = nil

		@Option(name: .long, help: "Indentation character")
		public var indentor: String? = nil

		@Option(name: .customLong("tab-size"), help: "Tab size")
		public var tabSize: Int? = nil

		@Option(name: .customLong("acronyms-processing"), help: "Acronyms processing")
		public var acronymsProcessing: String? = nil

		@Option(name: .long, help: "Acronyms to be treated as a single character in camelCasing")
		public var acronyms: [String] = ["__package_resources_unspecified"]

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
			name: .customLong("remove-tab-size"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes tab-size from the config file"
		)
		var removeTabSize: Bool = false

		@Flag(
			name: .customLong("remove-acronyms-processing"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes acronyms-processing from the config file"
		)
		var removeAcronymsProcessing: Bool = false

		@Flag(
			name: .customLong("remove-acronyms"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Removes acronyms from the config file"
		)
		var removeAcronyms: Bool = false

		func run() throws {
			let configFile = try File(path: parent.path)

			var (config, format) = App.CodableConfig.loadWithFormat(at: parent.path) ?? (.init(), .yaml)

			do {
				config = config
					.ifLet(output, override: \.output)
					.ifLet(indentor, override: \.indentor)
					.ifLet(tabSize, override: \.tabSize)
					.ifLet(acronymsProcessing, override: \.acronymsProcessing)

				if !(acronyms.count == 1 && acronyms[0] == "__package_resources_unspecified") {
					config.acronyms = acronyms
				}
			}

			do {
				if removeOutput { config.output = nil }
				if removeIndentor { config.indentor = nil }
				if removeTabSize { config.tabSize = nil }
				if removeAcronymsProcessing { config.acronymsProcessing = nil }
				if removeAcronyms { config.acronyms = nil }
			}

			let encodeJSON: () throws -> Void = {
				try configFile.write(JSONEncoder().encode(config))
			}

			let encodeYAML: () throws -> Void = {
				try configFile.write(YAMLEncoder().encode(config))
			}

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
}
