import ArgumentParser
import Foundation
import Casification
import PackageResourcesClient
import Yams

// MARK: - Command

struct App: AsyncParsableCommand {
	static let configuration: CommandConfiguration = .init(
		commandName: "package-resources-cli",
		abstract: "Code generator for https://github.com/capturecontext/swift-package-resources",
		version: "5.0.0",
		subcommands: [ConfigCommand.self, GenerateCommand.self]
	)
}
