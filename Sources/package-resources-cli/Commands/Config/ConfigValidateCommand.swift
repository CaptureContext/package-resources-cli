import ArgumentParser
import Foundation
import PackageResourcesManifest
import PackageResourcesFS
import Yams

extension App.ConfigCommand {
	struct ValidateCommand: ParsableCommand {
		static let configuration: CommandConfiguration = .init(
			commandName: "validate",
			abstract: "Validates configuration file",
			subcommands: []
		)

		@ParentCommand
		var parent: App.ConfigCommand

		func run() throws {
			let configFile = File(uncheckedPath: parent.path)
			let missing = (try? configFile.validatePath()) == nil

			if missing {
				throw _Error("⚠️ \(configFile.name) file is missing at \(parent.path) path")
			}

			_ = try Manifest.load(at: configFile.path)

			print(
				ANSI("✅ Successfully validated \(configFile.name) file")
					.foreground(.green)
					.bold()
			)
		}
	}
}
