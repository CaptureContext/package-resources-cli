import PackageResourcesCore
import XCStringsCatalog
import Dependencies
import IssueReporting

extension PackageResources.LocalizedString.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		@Dependency(\.formatClient.constants.groupXCStringsByCatalogName)
		var groupXCStringsByCatalogName

		return renderSnippet(.extensionDecl(
			name: PackageResources.LocalizedString.typeName,
			contents: renderXCStringsTree(
				for: resources,
				groupXCStringsByCatalogName: groupXCStringsByCatalogName
			)
		))
	}
}

private struct XCStringNode {
	var children: [String: XCStringNode] = [:]
	var accessors: [PackageResources.LocalizedString.Source] = []

	mutating func insert(
		_ resource: PackageResources.LocalizedString.Source,
		path: ArraySlice<String>
	) {
		guard let pathComponent = path.first else {
			accessors.append(resource)
			return
		}

		children[pathComponent, default: .init()]
			.insert(resource, path: path.dropFirst())
	}
}

private func renderXCStringsTree(
	for resources: [PackageResources.LocalizedString.Source],
	groupXCStringsByCatalogName: Bool
) -> String {
	var root = XCStringNode()

	for resource in resources {
		let keyPath = resource.resource.key.components(separatedBy: ".")
		let path: [String]
		if groupXCStringsByCatalogName, let table = resource.table {
			path = [table] + Array(keyPath.dropLast())
		} else {
			path = Array(keyPath.dropLast())
		}

		root.insert(resource, path: path[...])
	}

	return renderNode(root)
}

private func renderNode(_ node: XCStringNode) -> String {
	let children = node.children
		.sorted { $0.key < $1.key }
		.map { name, child in
			renderSnippet(.enumDecl(
				name: .identifier(name),
				contents: renderNode(child)
			))
		}

	let accessors = node.accessors
		.sorted { $0.resource.key < $1.resource.key }
		.map(renderAccessor)

	return renderSnippet(.join("\n\n") {
		children
		accessors
	})
}

private func renderAccessor(
	for source: PackageResources.LocalizedString.Source
) -> String {
	let resource = source.resource
	let identifier: some Snippet = .identifier(
		source.resource.key.components(separatedBy: ".").last
		?? source.resource.key
	)
	let body: some Snippet = .join(" ") {
		"return"
		renderSnippet(.methodCall(
			name: ".init",
			args: Array {
				Snippets.MethodCall.Argument(
					name: "key",
					value: source.resource.key.escapedUsingQuotes
				)
				Snippets.MethodCall.Argument(
					name: "arguments",
					value: renderArguments(source.resource.arguments)
				)
				Snippets.MethodCall.Argument(
					name: "table",
					value: source.table?.escapedUsingQuotes ?? "nil"
				)
				Snippets.MethodCall.Argument(
					name: "bundle",
					value: ".module"
				)
			}
		))
	}

	let returnType = "_XCStringResource"

	return renderSnippet(.join("\n") {
		"""
		/// "\(resource.sourceLocalization)"
		/// 
		/// > \(resource.comment ?? "<no_comment>")
		"""

		if resource.arguments.isEmpty {
			renderSnippet(.propertyDecl(
				identifier: identifier,
				returnType: returnType,
				body: body
			))
		} else {
			renderSnippet(.methodDecl(
				identifier: identifier,
				arguments: resource.arguments.map { argument in
					.init(
						label: argument.label ?? "_",
						name: .identifier(argument.name),
						type: swiftType(for: argument.placeholderType)
					)
				},
				returnType: returnType,
				body: body
			))
		}
	})
}

private func renderArguments(
	_ arguments: [XCStringResource.Argument]
) -> String {
	guard !arguments.isEmpty else { return "[]" }

	func renderArgumentValue(
	 for argument: XCStringResource.Argument
 ) -> String {
	 let _case = argument.placeholderType.rawValue
	 let _value = renderSnippet(.identifier(argument.name))
	 return ".\(_case)(\(_value))"
 }

	return renderSnippet(.bracketedBlock(
		in: .square,
		contents: .join(",\n") {
			arguments.map(renderArgumentValue)
		}
	))
}

private func swiftType(
	for type: XCStringResource.PlaceholderType
) -> String {
	switch type {
	case .int:
		return "Int"
	case .uint:
		return "UInt"
	case .float:
		return "Float"
	case .double:
		return "Double"
	case .object:
		return "String"
	}
}
