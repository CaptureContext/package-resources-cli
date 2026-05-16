import ArgumentParser
import Foundation
@_spi(Internals) import PackageResourcesManifest
import PackageResourcesFS
import Yams

extension App.ConfigCommand {
	struct InitCommand: ParsableCommand {
		enum Format: String, Codable, CaseIterable, ExpressibleByArgument {
			case yaml
			case json
			case keep
		}

		static let configuration: CommandConfiguration = .init(
			commandName: "init",
			abstract: "Creates default configuration file",
			subcommands: []
		)

		@ParentCommand
		var parent: App.ConfigCommand

		@Option(name: .shortAndLong, help: "Custom format")
		var format: Format = .keep

		@Flag(
			name: .customLong("encode-aliases"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Disables alias resolution for config values"
		)
		var encodeAliases: Bool = false

		@Flag(
			name: .customLong("force"),
			inversion: .prefixedNo,
			exclusivity: .exclusive,
			help: "Forces overwritting of an existing config file"
		)
		var force: Bool = false

		func run() throws {
			let configFile = File(uncheckedPath: parent.path)
			let missing = (try? configFile.validatePath()) == nil

			guard missing || force else {
				print(
					ANSI("✅ \(configFile.name) file already exists")
						.foreground(.yellow)
						.bold()
				)

				return
			}

			let config = Manifest()
			let format: Manifest.Format = self.format == .json ? .json : .yaml

			try Manifest.$encodeAliases.withValue(encodeAliases) {
				switch format {
				case .json:
					try configFile.write(JSONEncoder().encode(config))
				case .yaml:
					try configFile.write(YAMLEncoder().encode(config))
				}
			}

			print(
				ANSI("✅ Successfully created \(configFile.name) file")
					.foreground(.green)
					.bold()
			)
		}
	}
}
