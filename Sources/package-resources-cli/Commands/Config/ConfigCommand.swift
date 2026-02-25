import ArgumentParser
import Foundation
import PackageResourcesFS
import Yams

extension App {
	struct ConfigCommand: ParsableCommand {
		static let configuration: CommandConfiguration = .init(
			commandName: "config",
			abstract: "Manages configuration file.",
			subcommands: [InitCommand.self, EditCommand.self, ValidateCommand.self]
		)

		@Option(name: .shortAndLong, help: "Path to configuration file")
		var path: String = "./.packageresources"
	}
}
