import Dependencies
import Foundation
import PackageResourcesCore
import Snippets
import SwiftSnippets
import XCStringsCatalog

extension PackageResources.LocalizedString.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		@Dependency(\.resourceFormatConfig)
		var resourceFormatConfig
		let format = resourceFormatConfig.resolved(for: .xcStrings)

		let snippet = try Snippets.LocalizedStringsExtension(
			for: resources,
			groupByCatalogName: format.groupByCatalogName,
			splitByKeyPath: format.splitByKeyPath
		)

		return renderPackageResourceSnippet(snippet)
	}
}

struct XCStringResourceKeyPathConflict: Equatable, Sendable {
	var accessorKey: String
	var nestedKey: String
}

enum XCStringResourceValidationError: CustomStringConvertible, Equatable, LocalizedError {
	case conflictingKeyPaths([XCStringResourceKeyPathConflict])

	var description: String {
		errorDescription ?? "String resource validation error."
	}

	var errorDescription: String? {
		switch self {
		case let .conflictingKeyPaths(conflicts):
			let conflictDescriptions = conflicts
				.map { conflict in
					"""
					"\(conflict.accessorKey)" conflicts with "\(conflict.nestedKey)"
					"""
				}
				.joined(separator: ", ")

			return """
			String resource key path conflict: \(conflictDescriptions). \
			The accessor key would be generated where the nested key needs an enum namespace.
			"""
		}
	}
}

private struct XCStringNode {
	var children: [String: XCStringNode] = [:]
	var accessors: [PackageResources.LocalizedString.Source] = []

	mutating func insert(
		_ resource: PackageResources.LocalizedString.Source,
		path: ArraySlice<String>,
		splitByKeyPath: Bool,
		validateConflicts: Bool
	) throws {
		guard let pathComponent = path.first else {
			if validateConflicts, let child = children.first(where: { child in
				packageResourceIdentifierValue(child.key) == accessorIdentifier(
					for: resource,
					splitByKeyPath: splitByKeyPath
				)
			}) {
				throw XCStringResourceValidationError.conflictingKeyPaths([
					.init(
						accessorKey: resource.resource.key,
						nestedKey: child.value.firstResource?.resource.key ?? resource.resource.key
					)
				])
			}

			accessors.append(resource)
			return
		}

		if validateConflicts, let accessor = accessors.first(where: { accessor in
			accessorIdentifier(
				for: accessor,
				splitByKeyPath: splitByKeyPath
			) == packageResourceIdentifierValue(pathComponent)
		}) {
			throw XCStringResourceValidationError.conflictingKeyPaths([
				.init(
					accessorKey: accessor.resource.key,
					nestedKey: resource.resource.key
				)
			])
		}

		try children[pathComponent, default: .init()]
			.insert(
				resource,
				path: path.dropFirst(),
				splitByKeyPath: splitByKeyPath,
				validateConflicts: validateConflicts
			)
	}

	var firstResource: PackageResources.LocalizedString.Source? {
		accessors.first
			?? children
				.sorted { $0.key < $1.key }
				.lazy
				.compactMap(\.value.firstResource)
				.first
	}
}

private func accessorIdentifier(
	for source: PackageResources.LocalizedString.Source,
	splitByKeyPath: Bool
) -> String {
	let key = splitByKeyPath
		? source.resource.key.components(separatedBy: ".").last
		: source.resource.key

	return packageResourceIdentifierValue(
		key ?? source.resource.key
	)
}

extension Snippets {
	fileprivate struct LocalizedStringsExtension: Snippet {
		let root: XCStringNode
		let splitByKeyPath: Bool

		init(
			for resources: [PackageResources.LocalizedString.Source],
			groupByCatalogName: Bool,
			splitByKeyPath: Bool
		) throws {
			var root = XCStringNode()

			for resource in resources {
				let keyPath = resource.resource.key.components(separatedBy: ".")
				let path: [String]
				if splitByKeyPath, groupByCatalogName, let table = resource.table {
					path = [table] + Array(keyPath.dropLast())
				} else if splitByKeyPath {
					path = Array(keyPath.dropLast())
				} else if groupByCatalogName, let table = resource.table {
					path = [table]
				} else {
					path = []
				}

				try root.insert(
					resource,
					path: path[...],
					splitByKeyPath: splitByKeyPath,
					validateConflicts: splitByKeyPath
				)
			}

			self.root = root
			self.splitByKeyPath = splitByKeyPath
		}

		var content: some Snippet<String> {
			ExtensionDecl(
				extendedType: .init(snippetLiteral: PackageResources.LocalizedString.typeName)
			) {
				XCStringNodeContents(root, splitByKeyPath: splitByKeyPath)
			}
		}
	}

	private struct XCStringNodeContents: Snippet {
		let node: XCStringNode
		let splitByKeyPath: Bool

		init(
			_ node: XCStringNode,
			splitByKeyPath: Bool
		) {
			self.node = node
			self.splitByKeyPath = splitByKeyPath
		}

		var content: some Snippet<String> {
			Join(String.const(.newlines(2))) {
				node.children
					.sorted { $0.key < $1.key }
					.map { name, child in
						XCStringNodeEnum(
							name: name,
							node: child,
							splitByKeyPath: splitByKeyPath
						)
					}

				node.accessors
					.sorted { $0.resource.key < $1.resource.key }
					.map { source in
						XCStringAccessorDecl(source, splitByKeyPath: splitByKeyPath)
					}
			}
		}
	}

	private struct XCStringNodeEnum: Snippet {
		let name: String
		let node: XCStringNode
		let splitByKeyPath: Bool

		var content: some Snippet<String> {
			EnumDecl(
				accessLevel: .current,
				identifier: packageResourceIdentifier(name)
			) {
				XCStringNodeContents(node, splitByKeyPath: splitByKeyPath)
			}
		}
	}

	private struct XCStringAccessorDecl: Snippet {
		let source: PackageResources.LocalizedString.Source
		let splitByKeyPath: Bool

		init(
			_ source: PackageResources.LocalizedString.Source,
			splitByKeyPath: Bool
		) {
			self.source = source
			self.splitByKeyPath = splitByKeyPath
		}

		var resource: XCStringResource {
			source.resource
		}

		var identifier: IdentifierLiteral<String> {
			.init(
				snippetLiteral: accessorIdentifier(
					for: source,
					splitByKeyPath: splitByKeyPath
				)
			)
		}

		var content: some Snippet<String> {
			Join(String.const(.newline)) {
				Comment(.doc) {
					"""
					"\(resource.sourceLocalization)"
					
					> \(resource.comment ?? "<no_comment>")
					"""
				}

				if resource.arguments.isEmpty {
					ComputedPropertyDecl(
						accessLevel: .current,
						isStatic: true,
						identifier: identifier,
						type: TypeExpr(snippetLiteral: "_XCStringResource"),
						getter: PropertyGetterDecl {
							XCStringInitReturn(source)
						}
					)
				} else {
					FunctionDecl(
						accessLevel: .current,
						isStatic: true,
						identifier: identifier,
						parameters: SwiftFunctionParameterClause(
							resource.arguments.map(functionParameter)
						),
						returnType: TypeExpr(snippetLiteral: "_XCStringResource")
					) {
						XCStringInitReturn(source)
					}
				}
			}
		}

		private func functionParameter(
			for argument: XCStringResource.Argument
		) -> SwiftFunctionParameter {
			.init(
				label: packageResourceIdentifier(argument.label ?? "_"),
				name: packageResourceIdentifier(argument.name),
				type: TypeExpr(snippetLiteral: swiftType(for: argument.placeholderType))
			)
		}
	}

	private struct XCStringInitReturn: Snippet {
		let source: PackageResources.LocalizedString.Source

		init(_ source: PackageResources.LocalizedString.Source) {
			self.source = source
		}

		var content: some Snippet<String> {
			Join(String.const(.whitespace)) {
				"return"
				XCStringInitCall(source)
			}
		}
	}

	private struct XCStringInitCall: Snippet {
		let source: PackageResources.LocalizedString.Source

		init(_ source: PackageResources.LocalizedString.Source) {
			self.source = source
		}

		var content: some Snippet<String> {
			CallExpr(
				callee: ".init",
				clause: SwiftCallClause([
					SwiftCallArgument(
						label: .init("key"),
						value: source.resource.key.escapedUsingQuotes
					),
					SwiftCallArgument(
						label: .init("arguments"),
						value: XCStringArgumentsLiteral(source.resource.arguments)
					),
					SwiftCallArgument(
						label: .init("table"),
						value: source.table?.escapedUsingQuotes ?? "nil"
					),
					SwiftCallArgument(
						label: .init("bundle"),
						value: ".module"
					)
				])
			)
		}
	}

	private struct XCStringArgumentsLiteral: Snippet {
		let arguments: [XCStringResource.Argument]

		init(_ arguments: [XCStringResource.Argument]) {
			self.arguments = arguments
		}

		func render() -> String {
			ArrayLiteral(
				arguments.map { AnySnippet(XCStringArgumentValue($0)) }
			)
			.render()
		}
	}

	private struct XCStringArgumentValue: Snippet {
		let argument: XCStringResource.Argument

		init(_ argument: XCStringResource.Argument) {
			self.argument = argument
		}

		var content: some Snippet<String> {
			CallExpr(
				callee: ".\(argument.placeholderType.rawValue)",
				clause: SwiftCallClause([
					SwiftCallArgument(
						value: packageResourceIdentifier(argument.name)
					)
				])
			)
		}
	}
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
