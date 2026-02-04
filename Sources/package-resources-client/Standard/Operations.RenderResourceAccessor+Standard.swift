import PackageResourcesCore
import Casification

extension PackageResourcesClient.Operations.RenderResourceAccessor {
	public static func standard(
		indent: PackageResourcesClient.Operations.IndentUp = .standard(),
		camelCase: PackageResourcesClient.Operations.CamelCase = .standard(.camel)
	) -> PackageResourcesClient.Operations.RenderResourceAccessor {
		return .init { resource in
			Result {
				RenderedAccessor(
					initialResource: resource,
					stringValue: {
						switch resource {
						case let .color(resource):
							return accessor(
								for: resource,
								indent: indent.call,
								camelCase: camelCase.call
							)

						case let .image(resource):
							return accessor(
								for: resource,
								indent: indent.call,
								camelCase: camelCase.call
							)

						case let .font(resource):
							return accessor(
								for: resource,
								indent: indent.call,
								camelCase: camelCase.call
							)

						case let .nib(resource):
							return accessor(
								for: resource,
								indent: indent.call,
								camelCase: camelCase.call
							)

						case let .scene(resource):
							return accessor(
								for: resource,
								indent: indent.call,
								camelCase: camelCase.call
							)

						case let .storyboard(resource):
							return accessor(
								for: resource,
								indent: indent.call,
								camelCase: camelCase.call
							)
						}
					}()
				)
			}
		}
	}
}

fileprivate func accessor(
	for resource: PRCLIColorResource,
	indent: PackageResourcesClient.Operations.IndentUp.SyncSignature,
	camelCase: PackageResourcesClient.Operations.CamelCase.SyncSignature
) -> String {
	let accessorName = camelCase(resource.name)
	let resourceName = resource.name.escapedUsingQuotes
	return """
	\(indent(0)("public static var \(accessorName): Self {"))
	\(indent(1)("return .init(name: \(resourceName), bundle: .module)"))
	\(indent(0)("}"))
	"""
}

fileprivate func accessor(
	for resource: PRCLIImageResource,
	indent: PackageResourcesClient.Operations.IndentUp.SyncSignature,
	camelCase: PackageResourcesClient.Operations.CamelCase.SyncSignature
) -> String {
	let accessorName = camelCase(resource.name)
	let resourceName = resource.name.escapedUsingQuotes
	return """
	\(indent(0)("public static var \(accessorName): Self {"))
	\(indent(1)("return .init(name: \(resourceName), bundle: .module)"))
	\(indent(0)("}"))
	"""
}

fileprivate func accessor(
	for resource: PRCLIFontResource,
	indent: PackageResourcesClient.Operations.IndentUp.SyncSignature,
	camelCase: PackageResourcesClient.Operations.CamelCase.SyncSignature
) -> String {
	let accessorName = camelCase(resource.name)
	let resourceName = resource.name.escapedUsingQuotes
	return """
	\(indent(0)("public static var \(accessorName): Self {"))
	\(indent(1)("return .init(name: \(resourceName))"))
	\(indent(0)("}"))
	"""
}

fileprivate func accessor(
	for resource: PRCLINibResource,
	indent: PackageResourcesClient.Operations.IndentUp.SyncSignature,
	camelCase: PackageResourcesClient.Operations.CamelCase.SyncSignature
) -> String {
	let accessorName = camelCase(resource.name)
	let resourceName = resource.name.escapedUsingQuotes
	return """
	\(indent(0)("public static var \(accessorName): Self {"))
	\(indent(1)("return .init(name: \(resourceName), bundle: .module)"))
	\(indent(0)("}"))
	"""
}

fileprivate func accessor(
	for resource: PRCLISCNSceneResource,
	indent: PackageResourcesClient.Operations.IndentUp.SyncSignature,
	camelCase: PackageResourcesClient.Operations.CamelCase.SyncSignature
) -> String {
	let accessorName = camelCase(resource.name)
	let resourceName = resource.name.escapedUsingQuotes
	let catalog = resource.catalog.map { ", catalog: \($0.escapedUsingQuotes)" } ?? ""
	return """
	\(indent(0)("public static var \(accessorName): Self {"))
	\(indent(1)("return .init(name: \(resourceName)\(catalog), bundle: .module)"))
	\(indent(0)("}"))
	"""
}

fileprivate func accessor(
	for resource: PRCLIStoryboardResource,
	indent: PackageResourcesClient.Operations.IndentUp.SyncSignature,
	camelCase: PackageResourcesClient.Operations.CamelCase.SyncSignature
) -> String {
	let accessorName = camelCase(resource.name)
	let resourceName = resource.name.escapedUsingQuotes
	return """
	\(indent(0)("public static var \(accessorName): Self {"))
	\(indent(1)("return .init(name: \(resourceName), bundle: .module)"))
	\(indent(0)("}"))
	"""
}
