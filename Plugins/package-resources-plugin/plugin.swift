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

		try FileManager.default.createDirectory(
			atPath: outputDirectoryURL.path(),
			withIntermediateDirectories: true
		)

		let outputURL = outputDirectoryURL
			.appending(component: "Resources.generated.swift")

		return [
			.buildCommand(
				displayName: "Run package-resources-plugin for \(target.name)",
				executable: try context.tool(named: "package-resources-cli").url,
				arguments: [
					"generate",
					"--input", String(describing: target.directory),
					"--config", context.package.directoryURL.appending(component: ".packageresources").path(),
					"--output", outputURL.path()
				],
				outputFiles: [
					outputURL
				]
			)
		]
	}
}
