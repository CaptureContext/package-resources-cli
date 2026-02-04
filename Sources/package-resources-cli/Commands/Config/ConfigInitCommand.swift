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
			case append
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

			var config = App.Config.default
			var format: App.CodableConfig.Format = self.format == .json ? .json : .yaml

			if mode == .append, let existing = App.CodableConfig.loadWithFormat(at: parent.path) {
				config = config.applying(existing.config)
				if self.format == .keep { format = existing.format }
			}

			switch format {
			case .json:
				try configFile.write(JSONEncoder().encode(config.asCodable()))
			case .yaml:
				try configFile.write(YAMLEncoder().encode(config.asCodable()))
			}
		}
	}
}
