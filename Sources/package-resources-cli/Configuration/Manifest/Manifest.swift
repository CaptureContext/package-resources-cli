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
		version: Version = .init(major: 3),
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
