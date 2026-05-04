import Casification
import PackageResourcesClient

public struct Manifest {
	@TaskLocal
	@_spi(Internals)
	public static var encodeAliases: Bool = false

	public var version: Version
	public var output: String?
	public var indentor: Indentor
	public var indentSize: IndentSize
	public var accessLevel: AccessLevelConfig
	public var groupXCStringsByCatalogName: Bool
	public var resourceTypes: ResourceTypes
	public var numbers: NumbersConfig
	public var acronyms: AcronymsConfig

	public init(
		version: Version = .init(major: 3),
		output: String? = nil,
		indentor: Indentor = .default,
		indentSize: IndentSize = .default,
		accessLevel: AccessLevelConfig = .default,
		groupXCStringsByCatalogName: Bool = true,
		resourceTypes: ResourceTypes = .default,
		numbers: NumbersConfig = .default,
		acronyms: AcronymsConfig = .default
	) {
		self.version = version
		self.output = output
		self.indentor = indentor
		self.indentSize = indentSize
		self.accessLevel = accessLevel
		self.groupXCStringsByCatalogName = groupXCStringsByCatalogName
		self.resourceTypes = resourceTypes
		self.numbers = numbers
		self.acronyms = acronyms
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
