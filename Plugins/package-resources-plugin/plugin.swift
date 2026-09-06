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
		var visitedDirectories: Set<URL> = []
		var inputURLs = try resourceInputURLs(
			in: target.directoryURL,
			excluding: buildDirectory(containing: context.pluginWorkDirectoryURL),
			visitedDirectories: &visitedDirectories
		)
		if let configURL, !inputURLs.contains(configURL) {
			inputURLs.append(configURL)
		}

		inputURLs = Array(Set(inputURLs)).sorted { $0.path < $1.path }

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

	/// SwiftPM writes this state at the active scratch root before evaluating plugins.
	/// Locate it from our output path so custom scratch directory names are also excluded.
	private func buildDirectory(containing pluginWorkDirectory: URL) -> URL {
		var directory = pluginWorkDirectory.resolvingSymlinksInPath()
		while directory.path != "/" {
			let state = directory.appending(component: "workspace-state.json")
			let plugins = directory.appending(component: "plugins")
			if FileManager.default.fileExists(atPath: state.path),
				FileManager.default.fileExists(atPath: plugins.path) {
				return directory
			}
			directory.deleteLastPathComponent()
		}
		return pluginWorkDirectory.resolvingSymlinksInPath()
	}

	/// Files track edits; directories also track additions and removals between builds.
	private func resourceInputURLs(
		in directory: URL,
		excluding pluginWorkDirectory: URL,
		visitedDirectories: inout Set<URL>
	) throws -> [URL] {
		guard
			![".build", ".git"].contains(directory.lastPathComponent),
			directory.resolvingSymlinksInPath() != pluginWorkDirectory,
			visitedDirectories.insert(directory.resolvingSymlinksInPath()).inserted
		else { return [] }

		var inputs = [directory]
		let children = try FileManager.default.contentsOfDirectory(
			at: directory,
			includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey]
		).sorted { $0.path() < $1.path() }
		for child in children {
			let values = try child.resourceValues(forKeys: [.isDirectoryKey, .isSymbolicLinkKey])
			if values.isSymbolicLink == true {
				let destination = child.resolvingSymlinksInPath()
				guard FileManager.default.fileExists(atPath: destination.path),
					destination != pluginWorkDirectory,
					!destination.path.hasPrefix(pluginWorkDirectory.path + "/") else { continue }
				inputs.append(child) // Retargeting the link also invalidates generation.
				if let destinationValues = try? destination.resourceValues(forKeys: [.isDirectoryKey]) {
					if destinationValues.isDirectory == true {
						inputs += try resourceInputURLs(in: destination, excluding: pluginWorkDirectory,
							visitedDirectories: &visitedDirectories)
					} else {
						inputs.append(destination)
					}
				}
			} else if values.isDirectory == true {
				inputs += try resourceInputURLs(in: child, excluding: pluginWorkDirectory,
					visitedDirectories: &visitedDirectories)
			} else {
				inputs.append(child)
			}
		}
		return inputs
	}
}
