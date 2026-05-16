import Casification
import Dependencies
import FunctionComposition

extension DependencyValues {
	private enum ResourceFormatConfigKey: DependencyKey {
		static var liveValue: ResourceFormatConfig { .standard() }
		static var testValue: ResourceFormatConfig { .standard() }
	}

	private enum GeneratedResourcesDisclaimerProviderKey: DependencyKey {
		static var liveValue: SendableSyncFunc<String, String?> {
			.standardGeneratedResourcesDisclaimer
		}
		static var testValue: SendableSyncFunc<String, String?> {
			.standardGeneratedResourcesDisclaimer
		}
	}

	public var resourceFormatConfig: ResourceFormatConfig {
		get { self[ResourceFormatConfigKey.self] }
		set { self[ResourceFormatConfigKey.self] = newValue }
	}

	public var generatedResourcesDisclaimerProvider: SendableSyncFunc<String, String?> {
		get { self[GeneratedResourcesDisclaimerProviderKey.self] }
		set { self[GeneratedResourcesDisclaimerProviderKey.self] = newValue }
	}
}

public struct ResourceFormatConfig: Sendable {
	public enum ResourceKind: Hashable, Sendable {
		case colors
		case images
		case fonts
		case nibs
		case scnScenes
		case storyboards
		case xcStrings
	}

	@TaskLocal
	public static var currentResourceKind: ResourceKind?

	public struct Common: Sendable {
		public var indentor: String
		public var accessLevel: AccessLevel?
		public var updateCasification: @Sendable (inout String.Casification.Configuration) -> Void

		public init(
			indentor: String = "\t",
			accessLevel: AccessLevel? = .internal,
			updateCasification: @escaping @Sendable (inout String.Casification.Configuration) -> Void = { _ in }
		) {
			self.indentor = indentor
			self.accessLevel = accessLevel
			self.updateCasification = updateCasification
		}
	}

	public struct Catalog: Sendable {
		public var common: Common
		public var groupByCatalogName: Bool

		public init(
			common: Common = .init(),
			groupByCatalogName: Bool = true
		) {
			self.common = common
			self.groupByCatalogName = groupByCatalogName
		}
	}

	public struct AssetCatalog: Sendable {
		public var common: Common
		public var groupByCatalogName: Bool
		public var groupByFolders: Bool
		public var splitByKeyPath: Bool

		public init(
			common: Common = .init(),
			groupByCatalogName: Bool = true,
			groupByFolders: Bool = true,
			splitByKeyPath: Bool = true
		) {
			self.common = common
			self.groupByCatalogName = groupByCatalogName
			self.groupByFolders = groupByFolders
			self.splitByKeyPath = splitByKeyPath
		}
	}

	public struct XCStrings: Sendable {
		public var catalog: Catalog
		public var splitByKeyPath: Bool

		public init(
			catalog: Catalog = .init(),
			splitByKeyPath: Bool = true
		) {
			self.catalog = catalog
			self.splitByKeyPath = splitByKeyPath
		}
	}

	public struct Resolved: Sendable {
		public var common: Common
		public var groupByCatalogName: Bool
		public var groupByFolders: Bool
		public var splitByKeyPath: Bool

		public var indentor: String { common.indentor }
		public var accessLevel: AccessLevel? { common.accessLevel }
		public var updateCasification: @Sendable (inout String.Casification.Configuration) -> Void {
			common.updateCasification
		}

		public init(
			common: Common = .init(),
			groupByCatalogName: Bool = true,
			groupByFolders: Bool = true,
			splitByKeyPath: Bool = true
		) {
			self.common = common
			self.groupByCatalogName = groupByCatalogName
			self.groupByFolders = groupByFolders
			self.splitByKeyPath = splitByKeyPath
		}
	}

	public var colors: AssetCatalog
	public var images: AssetCatalog
	public var fonts: Common
	public var nibs: Common
	public var scnScenes: Common
	public var storyboards: Common
	public var xcStrings: XCStrings
	public var defaultFormat: Resolved

	public init(
		colors: AssetCatalog = .init(),
		images: AssetCatalog = .init(),
		fonts: Common = .init(),
		nibs: Common = .init(),
		scnScenes: Common = .init(),
		storyboards: Common = .init(),
		xcStrings: XCStrings = .init(),
		defaultFormat: Resolved = .init()
	) {
		self.colors = colors
		self.images = images
		self.fonts = fonts
		self.nibs = nibs
		self.scnScenes = scnScenes
		self.storyboards = storyboards
		self.xcStrings = xcStrings
		self.defaultFormat = defaultFormat
	}

	public var current: Resolved {
		resolved(for: Self.currentResourceKind)
	}

	public func resolved(for resourceKind: ResourceKind?) -> Resolved {
		switch resourceKind {
		case nil:
			defaultFormat
		case .some(.colors):
			Resolved(
				common: colors.common,
				groupByCatalogName: colors.groupByCatalogName,
				groupByFolders: colors.groupByFolders,
				splitByKeyPath: colors.splitByKeyPath
			)
		case .some(.images):
			Resolved(
				common: images.common,
				groupByCatalogName: images.groupByCatalogName,
				groupByFolders: images.groupByFolders,
				splitByKeyPath: images.splitByKeyPath
			)
		case .some(.fonts):
			Resolved(common: fonts)
		case .some(.nibs):
			Resolved(common: nibs)
		case .some(.scnScenes):
			Resolved(common: scnScenes)
		case .some(.storyboards):
			Resolved(common: storyboards)
		case .some(.xcStrings):
			Resolved(
				common: xcStrings.catalog.common,
				groupByCatalogName: xcStrings.catalog.groupByCatalogName,
				groupByFolders: false,
				splitByKeyPath: xcStrings.splitByKeyPath
			)
		}
	}

	public func withFormat<T>(
		for resourceKind: ResourceKind,
		operation: () throws -> T
	) rethrows -> T {
		try Self.$currentResourceKind.withValue(resourceKind) {
			let format = resolved(for: resourceKind)
			return try withCasification(format.updateCasification) {
				try operation()
			}
		}
	}
}

extension ResourceFormatConfig {
	public static func standard(
		indentor: String = "\t",
		indentSize: Int = 1,
		accessLevel: AccessLevel? = .internal,
		groupByCatalogName: Bool = true,
		groupByFolders: Bool = true,
		splitByKeyPath: Bool = true
	) -> Self {
		let common = Common(
			indentor: String(repeating: indentor, count: indentSize),
			accessLevel: accessLevel
		)
		let catalog = Catalog(
			common: common,
			groupByCatalogName: groupByCatalogName
		)
		let assetCatalog = AssetCatalog(
			common: common,
			groupByCatalogName: groupByCatalogName,
			groupByFolders: groupByFolders,
			splitByKeyPath: splitByKeyPath
		)

		return .init(
			colors: assetCatalog,
			images: assetCatalog,
			fonts: common,
			nibs: common,
			scnScenes: common,
			storyboards: common,
			xcStrings: .init(
				catalog: catalog,
				splitByKeyPath: splitByKeyPath
			),
			defaultFormat: .init(
				common: common,
				groupByCatalogName: groupByCatalogName,
				groupByFolders: groupByFolders,
				splitByKeyPath: splitByKeyPath
			)
		)
	}
}

private extension SendableSyncFunc where Input == String, Output == String? {
	static var standardGeneratedResourcesDisclaimer: Self {
		.init { filename in
			"""
			//
			// \(filename)
			// This file is generated. Do not edit!
			//
			"""
		}
	}
}
