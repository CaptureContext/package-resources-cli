import FunctionComposition
import Dependencies
import Casification

extension DependencyValues {
	private enum FormatClientKey: DependencyKey {
		static var liveValue: FormatClient { .standard() }
		static var testValue: FormatClient { .standard() }
	}

	public var formatClient: FormatClient {
		get { self[FormatClientKey.self] }
		set { self[FormatClientKey.self] = newValue }
	}
}

public struct FormatClient: Sendable {
	public struct Constants {
		public var accessLevel: AccessLevel?
		public var groupXCStringsByCatalogName: Bool

		public init(
			accessLevel: AccessLevel? = .internal,
			groupXCStringsByCatalogName: Bool = true
		) {
			self.accessLevel = accessLevel
			self.groupXCStringsByCatalogName = groupXCStringsByCatalogName
		}
	}

	public var indentUp: SendableSyncFunc<Int, SendableSyncFunc<String, String>>
	public var camelCase: SendableSyncFunc<String, String>
	public var constantsProvider: SendableSyncFunc<Void, Constants>
	public var disclaimerProvider: SendableSyncFunc<String, String?>

	public var constants: Constants {
		constantsProvider()
	}

	public init(
		indentUp: SendableSyncFunc<Int, SendableSyncFunc<String, String>>,
		camelCase: SendableSyncFunc<String, String>,
		constantsProvider: SendableSyncFunc<Void, Constants>,
		disclaimerProvider: SendableSyncFunc<String, String?>
	) {
		self.indentUp = indentUp
		self.camelCase = camelCase
		self.constantsProvider = constantsProvider
		self.disclaimerProvider = disclaimerProvider
	}
}

extension FormatClient {
	public static func standard(
		indentor: String = "\t",
		indentSize: Int = 1,
		camelCaseMode: String.Casification.Configuration.CamelCase.Mode = .camel,
		accessLevel: AccessLevel? = .internal,
		groupXCStringsByCatalogName: Bool = true
	) -> Self {
		let _indentor = String(repeating: indentor, count: indentSize)
		return .init(
			indentUp: .init { level in
				return .init { source in
					source.components(separatedBy: .newlines)
						.map {
							if $0.isEmpty { return $0 }
							else { return String(repeating: _indentor, count: level) + $0 }
						}
						.joined(separator: "\n")
				}
			},
			camelCase: .init { input in
				input.case(.camel(camelCaseMode))
			},
			constantsProvider: .init {
				.init(
					accessLevel: accessLevel,
					groupXCStringsByCatalogName: groupXCStringsByCatalogName
				)
			},
			disclaimerProvider: .init { filename in
				"""
				//
				// \(filename)
				// This file is generated. Do not edit!
				//
				"""
			}
		)
	}
}
