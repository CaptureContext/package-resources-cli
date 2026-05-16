import Casification
import PackageResourcesClient

public struct Manifest {
	@TaskLocal
	@_spi(Internals)
	public static var encodeAliases: Bool = false

	public var version: Version
	public var output: String?
	public var format: FormatConfig
	public var resourceTypes: ResourceTypes

	public init(
		version: Version = .init(major: 4),
		output: String? = nil,
		format: FormatConfig = .init(),
		resourceTypes: ResourceTypes = .default,
	) {
		self.version = version
		self.output = output
		self.format = format
		self.resourceTypes = resourceTypes
	}
}

extension Manifest {
	public var enabledResourceTypes: EnabledResourceTypes {
		version.major >= 4
			? format.enabledResourceTypes
			: resourceTypes.enabledResourceTypes
	}

	public var indentor: Indentor {
		get { format.root.indentor }
		set { format.updateRoot { $0.indentor = newValue } }
	}

	public var indentSize: IndentSize {
		get { format.root.indentSize }
		set { format.updateRoot { $0.indentSize = newValue } }
	}

	public var accessLevel: AccessLevelConfig {
		get { format.root.accessLevel }
		set { format.updateRoot { $0.accessLevel = newValue } }
	}

	public var numbers: NumbersConfig {
		get { format.root.numbers }
		set { format.updateRoot { $0.numbers = newValue } }
	}

	public var acronyms: AcronymsConfig {
		get { format.root.acronyms }
		set { format.updateRoot { $0.acronyms = newValue } }
	}

	public var groupByCatalogName: Bool {
		get { format.root.groupByCatalogName }
		set { format.updateRoot { $0.groupByCatalogName = newValue } }
	}

	public var groupXCStringsByCatalogName: Bool {
		get { format.xcStrings.resolved.groupByCatalogName }
		set { format.xcStrings.update { $0.groupByCatalogName = newValue } }
	}

	public var xcStringsSplitByKeyPath: Bool {
		get { format.xcStrings.resolved.splitByKeyPath }
		set { format.xcStrings.update { $0.splitByKeyPath = newValue } }
	}

	public var colorsGroupByFolders: Bool {
		get { format.colors.resolved.groupByFolders }
		set { format.colors.update { $0.groupByFolders = newValue } }
	}

	public var imagesGroupByFolders: Bool {
		get { format.images.resolved.groupByFolders }
		set { format.images.update { $0.groupByFolders = newValue } }
	}

	public var colorsSplitByKeyPath: Bool {
		get { format.colors.resolved.splitByKeyPath }
		set { format.colors.update { $0.splitByKeyPath = newValue } }
	}

	public var imagesSplitByKeyPath: Bool {
		get { format.images.resolved.splitByKeyPath }
		set { format.images.update { $0.splitByKeyPath = newValue } }
	}

	public var ignoreColors: Bool {
		get { format.colors.resolved.ignore }
		set { format.colors.update { $0.ignore = newValue } }
	}

	public var ignoreImages: Bool {
		get { format.images.resolved.ignore }
		set { format.images.update { $0.ignore = newValue } }
	}

	public var ignoreFonts: Bool {
		get { format.fonts.resolved.ignore }
		set { format.fonts.update { $0.ignore = newValue } }
	}

	public var ignoreNibs: Bool {
		get { format.nibs.resolved.ignore }
		set { format.nibs.update { $0.ignore = newValue } }
	}

	public var ignoreStoryboards: Bool {
		get { format.storyboards.resolved.ignore }
		set { format.storyboards.update { $0.ignore = newValue } }
	}

	public var ignoreXCStrings: Bool {
		get { format.xcStrings.resolved.ignore }
		set { format.xcStrings.update { $0.ignore = newValue } }
	}
}

extension Manifest {
	public mutating func ifLet<T>(
		_ value: T?,
		set keyPath: WritableKeyPath<Manifest, T>
	) {
		self = ifLet(value, override: keyPath)
	}

	public func ifLet<T>(
		_ value: T?,
		override keyPath: WritableKeyPath<Manifest, T>
	) -> Self {
		if let value {
			reduce(self) { $0[keyPath: keyPath] = value }
		} else {
			self
		}
	}
}
