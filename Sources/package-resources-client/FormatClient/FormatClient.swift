import FunctionComposition
import Dependencies

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
		public var indentor: String
		public var accessLevel: AccessLevel?
		public var groupXCStringsByCatalogName: Bool

		public init(
			indentor: String = "\t",
			accessLevel: AccessLevel? = .internal,
			groupXCStringsByCatalogName: Bool = true
		) {
			self.indentor = indentor
			self.accessLevel = accessLevel
			self.groupXCStringsByCatalogName = groupXCStringsByCatalogName
		}
	}

	public var constantsProvider: SendableSyncFunc<Void, Constants>
	public var disclaimerProvider: SendableSyncFunc<String, String?>

	public var constants: Constants {
		constantsProvider()
	}

	public init(
		constantsProvider: SendableSyncFunc<Void, Constants>,
		disclaimerProvider: SendableSyncFunc<String, String?>
	) {
		self.constantsProvider = constantsProvider
		self.disclaimerProvider = disclaimerProvider
	}
}

extension FormatClient {
	public static func standard(
		indentor: String = "\t",
		indentSize: Int = 1,
		accessLevel: AccessLevel? = .internal,
		groupXCStringsByCatalogName: Bool = true
	) -> Self {
		let _indentor = String(repeating: indentor, count: indentSize)
		return .init(
			constantsProvider: .init {
				.init(
					indentor: _indentor,
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
