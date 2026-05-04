import PackagePlugin
import Foundation

@main
struct PackageResourcesPlugin: BuildToolPlugin {
	func createBuildCommands(
		context: PluginContext,
		target: Target
	) async throws -> [Command] {
		guard let target = target as? SourceModuleTarget else { return [] }

		let outputDirectoryURL = context.pluginWorkDirectoryURL
			.appending(component: target.name)

		let fileManager = FileManager.default

		try fileManager.createDirectory(
			atPath: outputDirectoryURL.path(),
			withIntermediateDirectories: true
		)

		let outputURL = outputDirectoryURL
			.appending(component: "Resources.generated.swift")

		let configName = ".packageresources"

		let targetConfigURL = target.directoryURL
			.appending(component: configName)

		let packageConfigURL = context.package.directoryURL
			.appending(component: configName)

		let configURL: URL? = switch true {
		case fileManager.fileExists(atPath: targetConfigURL.path()):
			targetConfigURL
		case fileManager.fileExists(atPath: packageConfigURL.path()):
			packageConfigURL
		default:
			nil
		}

		let inputArgs: [String] = ["--input", target.directoryURL.path()]
		let outputArgs: [String] = ["--output", outputURL.path()]
		let configArgs: [String] = configURL.map { url in
			["--config", url.path()]
		} ?? []


		return [
			.buildCommand(
				displayName: "Run package-resources-plugin for \(target.name)",
				executable: try context.tool(named: "package-resources-cli").url,
				arguments: ["generate"]
				+ inputArgs
				+ outputArgs
				+ configArgs,
				outputFiles: [
					outputURL
				]
			)
		]
	}
}
