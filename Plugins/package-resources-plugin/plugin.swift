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
		var inputURLs = try resourceInputURLs(
			in: target.directoryURL,
			excluding: context.pluginWorkDirectoryURL.resolvingSymlinksInPath()
		)
		if let configURL, !inputURLs.contains(configURL) {
			inputURLs.append(configURL)
		}

		return [
			.buildCommand(
				displayName: "Run package-resources-plugin for \(target.name)",
				executable: try context.tool(named: "package-resources-cli").url,
				arguments: ["generate"]
				+ inputArgs
				+ outputArgs
				+ configArgs,
				inputFiles: inputURLs,
				outputFiles: [
					outputURL
				]
			)
		]
	}

	/// Files track edits; directories also track additions and removals between builds.
	private func resourceInputURLs(in directory: URL, excluding pluginWorkDirectory: URL) throws -> [URL] {
		guard
			![".build", ".git"].contains(directory.lastPathComponent),
			directory.resolvingSymlinksInPath() != pluginWorkDirectory
		else { return [] }

		var inputs = [directory]
		let children = try FileManager.default.contentsOfDirectory(
			at: directory,
			includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey]
		).sorted { $0.path() < $1.path() }
		for child in children {
			let values = try child.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
			if values.isDirectory == true && values.isSymbolicLink != true {
				inputs += try resourceInputURLs(in: child, excluding: pluginWorkDirectory)
			} else {
				inputs.append(child)
			}
		}
		return inputs
	}
}
