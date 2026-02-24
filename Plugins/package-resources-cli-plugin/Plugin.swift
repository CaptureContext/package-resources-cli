import PackagePlugin
import Foundation


@main
struct PackageResources: CommandPlugin {
	func performCommand(
		context: PluginContext,
		arguments: [String]
	) throws {
		let cli = try context.tool(named: "package-resources-cli")
		let process = try Process.run(cli.url, arguments: arguments)
		process.waitUntilExit()

		if process.terminationReason == .exit, process.terminationStatus == 0 {
			return
		} else {
			Diagnostics.error("""
			CLI invocation failed
			  status: \(process.terminationStatus)
			  reason: \(process.terminationReason)
			""")
		}
	}
}
