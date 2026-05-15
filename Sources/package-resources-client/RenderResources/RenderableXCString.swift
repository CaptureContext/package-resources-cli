import Dependencies
import PackageResourcesCore
import Snippets
import SwiftSnippets
import XCStringsCatalog

extension PackageResources.LocalizedString.Source: _RenderableResourceType {
	public static func render(_ resources: [Self]) throws -> String {
		guard !resources.isEmpty else { return "" }

		@Dependency(\.formatClient.constants.groupXCStringsByCatalogName)
		var groupXCStringsByCatalogName

		return renderPackageResourceSnippet(
			Snippets.LocalizedStringsExtension(
				for: resources,
				groupXCStringsByCatalogName: groupXCStringsByCatalogName
			)
		)
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

extension Snippets {
	fileprivate struct LocalizedStringsExtension: Snippet {
		let root: XCStringNode

		init(
			for resources: [PackageResources.LocalizedString.Source],
			groupXCStringsByCatalogName: Bool
		) {
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

			self.root = root
		}

		var content: some Snippet<String> {
			ExtensionDecl(
				extendedType: .init(snippetLiteral: PackageResources.LocalizedString.typeName)
			) {
				XCStringNodeContents(root)
			}
		}
	}

	private struct XCStringNodeContents: Snippet {
		let node: XCStringNode

		init(_ node: XCStringNode) {
			self.node = node
		}

		var content: some Snippet<String> {
			Join(String.const(.newlines(2))) {
				node.children
					.sorted { $0.key < $1.key }
					.map { name, child in
						XCStringNodeEnum(name: name, node: child)
					}

				node.accessors
					.sorted { $0.resource.key < $1.resource.key }
					.map { source in
						XCStringAccessorDecl(source)
					}
			}
		}
	}

	private struct XCStringNodeEnum: Snippet {
		let name: String
		let node: XCStringNode

		var content: some Snippet<String> {
			EnumDecl(
				accessLevel: .current,
				identifier: packageResourceIdentifier(name)
			) {
				XCStringNodeContents(node)
			}
		}
	}

	private struct XCStringAccessorDecl: Snippet {
		let source: PackageResources.LocalizedString.Source

		init(_ source: PackageResources.LocalizedString.Source) {
			self.source = source
		}

		var resource: XCStringResource {
			source.resource
		}

		var identifier: IdentifierLiteral<String> {
			packageResourceIdentifier(
				resource.key.components(separatedBy: ".").last
				?? resource.key
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
