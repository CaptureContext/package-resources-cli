import Casification
import PackageResourcesFS

extension PackageResourcesClient.Operations.ProcessResources {
	public static func standard(render: ToString = .standard()) -> Self {
		return .init(stringOutput: render, fileOutput: .standard(render: render))
	}

	public static func standard(
		tabSize: Int,
		indentor: String,
		acronyms: String.Casification.Modifiers.CamelCaseConfig.Acronyms = .default
	) -> Self {
		let indent: PackageResourcesClient.Operations.IndentUp = .standard(
			tabSize: tabSize,
			indentor: indentor
		)

		let camelCase: PackageResourcesClient.Operations.CamelCase = .standard(
			.camel,
			acronyms: acronyms
		)

		return .standard(
			render: .standard(
				render: .standard(
					renderAccessor: .standard(
						indent: indent,
						camelCase: camelCase
					),
					camelCase: camelCase,
					indent: indent
				)
			)
		)
	}
}

extension PackageResourcesClient.Operations.ProcessResources.ToString {
	public static func standard(
		collect: PackageResourcesClient.Operations.CollectResources = .standard,
		render: PackageResourcesClient.Operations.RenderExtensions = .standard()
	) -> Self {
		return .init { path in
			collect(atPath: path)
				.flatMap(render.callAsFunction)
		}
	}
}

extension PackageResourcesClient.Operations.ProcessResources.ToFile {
	public static func standard(
		render: PackageResourcesClient.Operations.ProcessResources.ToString = .standard()
	) -> Self {
		return .init { input, output in
			Result {
				let processedResources = try render.call(input).get()
				let outputFile = try File(path: output, create: true)

				let disclaimer = """
				//
				// \(outputFile.name)
				// This file is generated. Do not edit!
				//
				"""

				let imports = """
				import Foundation
				import PackageResourcesCore
				"""

				let output = [
					disclaimer,
					imports,
					processedResources
				].joined(separator: "\n\n")

				try outputFile.write(output)
			}
		}
	}
}
