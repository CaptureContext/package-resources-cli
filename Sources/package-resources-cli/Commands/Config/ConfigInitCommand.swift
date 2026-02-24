import ArgumentParser
import Foundation
import PackageResourcesFS
import Yams

extension App.ConfigCommand {
	struct InitCommand: ParsableCommand {
		enum Format: String, Codable, CaseIterable, ExpressibleByArgument {
			case yaml
			case json
			case keep
		}

		enum Mode: String, Codable, CaseIterable, ExpressibleByArgument {
			case `default`
			case force
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

		@Option(name: .shortAndLong, help: "Initialization mode")
		var mode: Mode = .default

		func run() throws {
			let configFile = File(uncheckedPath: parent.path)
			let missing = (try? configFile.validatePath()) == nil

			guard missing || mode != .default else { return }

			let config = Manifest()
			let format: Manifest.Format = self.format == .json ? .json : .yaml

			switch format {
			case .json:
				try configFile.write(JSONEncoder().encode(config))
			case .yaml:
				try configFile.write(YAMLEncoder().encode(config))
			}
		}
	}
}
