import PackageResourcesClient

extension Manifest {
	public struct FormatConfig: Equatable, Sendable {
		@TaskLocal
		public static var root: Root = .default

		public var root: Root
		public var colors: CatalogResource
		public var images: CatalogResource
		public var fonts: CommonResource
		public var nibs: CommonResource
		public var storyboards: CommonResource
		public var xcStrings: XCStringsResource

		public init(
			root: Root = .default,
			colors: CatalogResource? = nil,
			images: CatalogResource? = nil,
			fonts: CommonResource? = nil,
			nibs: CommonResource? = nil,
			storyboards: CommonResource? = nil,
			xcStrings: XCStringsResource? = nil
		) {
			self.root = root
			self.colors = Self.$root.withValue(root) { colors ?? .inherited() }
			self.images = Self.$root.withValue(root) { images ?? .inherited() }
			self.fonts = Self.$root.withValue(root) { fonts ?? .inherited() }
			self.nibs = Self.$root.withValue(root) { nibs ?? .inherited() }
			self.storyboards = Self.$root.withValue(root) { storyboards ?? .inherited() }
			self.xcStrings = Self.$root.withValue(root) { xcStrings ?? .inherited() }
		}

		public var enabledResourceTypes: EnabledResourceTypes {
			var output: EnabledResourceTypes = []
			if !colors.resolved.ignore { output.insert(.colors) }
			if !images.resolved.ignore { output.insert(.images) }
			if !fonts.resolved.ignore { output.insert(.fonts) }
			if !nibs.resolved.ignore { output.insert(.nibs) }
			if !storyboards.resolved.ignore { output.insert(.storyboards) }
			if !xcStrings.resolved.ignore { output.insert(.xcStrings) }
			return output
		}

		public mutating func updateRoot(_ update: (inout Root) -> Void) {
			let oldRoot = root
			update(&root)

			colors.inheritValues(movingFrom: oldRoot, to: root)
			images.inheritValues(movingFrom: oldRoot, to: root)
			fonts.inheritValues(movingFrom: oldRoot, to: root)
			nibs.inheritValues(movingFrom: oldRoot, to: root)
			storyboards.inheritValues(movingFrom: oldRoot, to: root)
			xcStrings.inheritValues(movingFrom: oldRoot, to: root)
		}
	}
}

extension Manifest.FormatConfig {
	public enum Alias: String, Codable, Sendable {
		case `default`
	}

	public struct Root: Equatable, Sendable {
		public static let `default` = Self()

		public var indentor: Manifest.Indentor
		public var indentSize: Manifest.IndentSize
		public var accessLevel: Manifest.AccessLevelConfig
		public var numbers: Manifest.NumbersConfig
		public var acronyms: Manifest.AcronymsConfig
		public var groupByCatalogName: Bool

		public init(
			indentor: Manifest.Indentor = .default,
			indentSize: Manifest.IndentSize = .default,
			accessLevel: Manifest.AccessLevelConfig = .default,
			numbers: Manifest.NumbersConfig = .default,
			acronyms: Manifest.AcronymsConfig = .default,
			groupByCatalogName: Bool = true
		) {
			self.indentor = indentor
			self.indentSize = indentSize
			self.accessLevel = accessLevel
			self.numbers = numbers
			self.acronyms = acronyms
			self.groupByCatalogName = groupByCatalogName
		}
	}

	public struct Common: Codable, Equatable, Sendable {
		public var ignore: Bool
		public var indentor: Manifest.Indentor
		public var indentSize: Manifest.IndentSize
		public var accessLevel: Manifest.AccessLevelConfig
		public var numbers: Manifest.NumbersConfig
		public var acronyms: Manifest.AcronymsConfig

		public init(
			ignore: Bool = false,
			indentor: Manifest.Indentor = Manifest.FormatConfig.root.indentor,
			indentSize: Manifest.IndentSize = Manifest.FormatConfig.root.indentSize,
			accessLevel: Manifest.AccessLevelConfig = Manifest.FormatConfig.root.accessLevel,
			numbers: Manifest.NumbersConfig = Manifest.FormatConfig.root.numbers,
			acronyms: Manifest.AcronymsConfig = Manifest.FormatConfig.root.acronyms
		) {
			self.ignore = ignore
			self.indentor = indentor
			self.indentSize = indentSize
			self.accessLevel = accessLevel
			self.numbers = numbers
			self.acronyms = acronyms
		}

		public init(from decoder: any Decoder) throws {
			self = try decoder.decode { container in
				let root = Manifest.FormatConfig.root
				let indentor: Manifest.Indentor = try container.decodeIfPresent("indentor")
					.or(root.indentor)
				let indentSize: Manifest.IndentSize = try Manifest.Indentor.$current.withValue(indentor) {
					try container.decodeIfPresent("indent-size").or(root.indentSize)
				}

				return try Self(
					ignore: container.decodeIfPresent("ignore").or(false),
					indentor: indentor,
					indentSize: indentSize,
					accessLevel: container.decodeIfPresent("access-level").or(root.accessLevel),
					numbers: container.decodeIfPresent("numbers").or(root.numbers),
					acronyms: container.decodeIfPresent("acronyms").or(root.acronyms)
				)
			}
		}

		public func encode(to encoder: any Encoder) throws {
			try encoder.encode { container in
				try encodeContents(to: &container, relativeTo: Manifest.FormatConfig.root)
			}
		}

		func hasDifferences(relativeTo root: Root) -> Bool {
			ignore
				|| indentor != root.indentor
				|| indentSize != root.indentSize
				|| accessLevel != root.accessLevel
				|| numbers != root.numbers
				|| acronyms != root.acronyms
		}

		func encodeContents(
			to container: inout KeyedEncodingContainer<RawCodingKey>,
			relativeTo root: Root
		) throws {
			if ignore {
				try container.encode(ignore, forKey: "ignore")
			}
			if indentor != root.indentor {
				try container.encode(indentor, forKey: "indentor")
			}
			if indentSize != root.indentSize {
				try Manifest.Indentor.$current.withValue(indentor) {
					try container.encode(indentSize, forKey: "indent-size")
				}
			}
			if accessLevel != root.accessLevel {
				try container.encode(accessLevel, forKey: "access-level")
			}
			if numbers != root.numbers {
				try container.encode(numbers, forKey: "numbers")
			}
			if acronyms != root.acronyms {
				try container.encode(acronyms, forKey: "acronyms")
			}
		}

		mutating func inheritValues(
			movingFrom oldRoot: Root,
			to newRoot: Root
		) {
			if indentor == oldRoot.indentor { indentor = newRoot.indentor }
			if indentSize == oldRoot.indentSize { indentSize = newRoot.indentSize }
			if accessLevel == oldRoot.accessLevel { accessLevel = newRoot.accessLevel }
			if numbers == oldRoot.numbers { numbers = newRoot.numbers }
			if acronyms == oldRoot.acronyms { acronyms = newRoot.acronyms }
		}
	}

	public struct Catalog: Codable, Equatable, Sendable {
		public var common: Common
		public var groupByCatalogName: Bool

		public var ignore: Bool {
			get { common.ignore }
			set { common.ignore = newValue }
		}
		public var indentor: Manifest.Indentor {
			get { common.indentor }
			set { common.indentor = newValue }
		}
		public var indentSize: Manifest.IndentSize {
			get { common.indentSize }
			set { common.indentSize = newValue }
		}
		public var accessLevel: Manifest.AccessLevelConfig {
			get { common.accessLevel }
			set { common.accessLevel = newValue }
		}
		public var numbers: Manifest.NumbersConfig {
			get { common.numbers }
			set { common.numbers = newValue }
		}
		public var acronyms: Manifest.AcronymsConfig {
			get { common.acronyms }
			set { common.acronyms = newValue }
		}

		public init(
			ignore: Bool = false,
			indentor: Manifest.Indentor = Manifest.FormatConfig.root.indentor,
			indentSize: Manifest.IndentSize = Manifest.FormatConfig.root.indentSize,
			accessLevel: Manifest.AccessLevelConfig = Manifest.FormatConfig.root.accessLevel,
			numbers: Manifest.NumbersConfig = Manifest.FormatConfig.root.numbers,
			acronyms: Manifest.AcronymsConfig = Manifest.FormatConfig.root.acronyms,
			groupByCatalogName: Bool = Manifest.FormatConfig.root.groupByCatalogName
		) {
			self.common = .init(
				ignore: ignore,
				indentor: indentor,
				indentSize: indentSize,
				accessLevel: accessLevel,
				numbers: numbers,
				acronyms: acronyms
			)
			self.groupByCatalogName = groupByCatalogName
		}

		public init(from decoder: any Decoder) throws {
			let common = try Common(from: decoder)
			self = try decoder.decode { container in
				try Self(
					ignore: common.ignore,
					indentor: common.indentor,
					indentSize: common.indentSize,
					accessLevel: common.accessLevel,
					numbers: common.numbers,
					acronyms: common.acronyms,
					groupByCatalogName: container.decodeIfPresent("group-by-catalog")
						.or(Manifest.FormatConfig.root.groupByCatalogName)
				)
			}
		}

		public func encode(to encoder: any Encoder) throws {
			try encoder.encode { container in
				try encodeContents(to: &container, relativeTo: Manifest.FormatConfig.root)
			}
		}

		func hasDifferences(relativeTo root: Root) -> Bool {
			common.hasDifferences(relativeTo: root)
				|| groupByCatalogName != root.groupByCatalogName
		}

		func encodeContents(
			to container: inout KeyedEncodingContainer<RawCodingKey>,
			relativeTo root: Root
		) throws {
			try common.encodeContents(to: &container, relativeTo: root)
			if groupByCatalogName != root.groupByCatalogName {
				try container.encode(groupByCatalogName, forKey: "group-by-catalog")
			}
		}

		mutating func inheritValues(
			movingFrom oldRoot: Root,
			to newRoot: Root
		) {
			common.inheritValues(movingFrom: oldRoot, to: newRoot)
			if groupByCatalogName == oldRoot.groupByCatalogName {
				groupByCatalogName = newRoot.groupByCatalogName
			}
		}
	}

	public struct XCStrings: Codable, Equatable, Sendable {
		public var catalog: Catalog
		public var splitByKeyPath: Bool

		public var ignore: Bool {
			get { catalog.ignore }
			set { catalog.ignore = newValue }
		}
		public var indentor: Manifest.Indentor {
			get { catalog.indentor }
			set { catalog.indentor = newValue }
		}
		public var indentSize: Manifest.IndentSize {
			get { catalog.indentSize }
			set { catalog.indentSize = newValue }
		}
		public var accessLevel: Manifest.AccessLevelConfig {
			get { catalog.accessLevel }
			set { catalog.accessLevel = newValue }
		}
		public var numbers: Manifest.NumbersConfig {
			get { catalog.numbers }
			set { catalog.numbers = newValue }
		}
		public var acronyms: Manifest.AcronymsConfig {
			get { catalog.acronyms }
			set { catalog.acronyms = newValue }
		}
		public var groupByCatalogName: Bool {
			get { catalog.groupByCatalogName }
			set { catalog.groupByCatalogName = newValue }
		}

		public init(
			ignore: Bool = false,
			indentor: Manifest.Indentor = Manifest.FormatConfig.root.indentor,
			indentSize: Manifest.IndentSize = Manifest.FormatConfig.root.indentSize,
			accessLevel: Manifest.AccessLevelConfig = Manifest.FormatConfig.root.accessLevel,
			numbers: Manifest.NumbersConfig = Manifest.FormatConfig.root.numbers,
			acronyms: Manifest.AcronymsConfig = Manifest.FormatConfig.root.acronyms,
			groupByCatalogName: Bool = Manifest.FormatConfig.root.groupByCatalogName,
			splitByKeyPath: Bool = true
		) {
			self.catalog = .init(
				ignore: ignore,
				indentor: indentor,
				indentSize: indentSize,
				accessLevel: accessLevel,
				numbers: numbers,
				acronyms: acronyms,
				groupByCatalogName: groupByCatalogName
			)
			self.splitByKeyPath = splitByKeyPath
		}

		public init(from decoder: any Decoder) throws {
			let catalog = try Catalog(from: decoder)
			self = try decoder.decode { container in
				try Self(
					ignore: catalog.ignore,
					indentor: catalog.indentor,
					indentSize: catalog.indentSize,
					accessLevel: catalog.accessLevel,
					numbers: catalog.numbers,
					acronyms: catalog.acronyms,
					groupByCatalogName: catalog.groupByCatalogName,
					splitByKeyPath: container.decodeIfPresent("split-by-key-path").or(true)
				)
			}
		}

		public func encode(to encoder: any Encoder) throws {
			try encoder.encode { container in
				try encodeContents(to: &container, relativeTo: Manifest.FormatConfig.root)
			}
		}

		func hasDifferences(relativeTo root: Root) -> Bool {
			catalog.hasDifferences(relativeTo: root) || !splitByKeyPath
		}

		func encodeContents(
			to container: inout KeyedEncodingContainer<RawCodingKey>,
			relativeTo root: Root
		) throws {
			try catalog.encodeContents(to: &container, relativeTo: root)
			if !splitByKeyPath {
				try container.encode(splitByKeyPath, forKey: "split-by-key-path")
			}
		}

		mutating func inheritValues(
			movingFrom oldRoot: Root,
			to newRoot: Root
		) {
			catalog.inheritValues(movingFrom: oldRoot, to: newRoot)
		}
	}

	public enum CommonResource: Codable, Equatable, Sendable {
		case alias(Alias)
		case value(Common)

		public static var `default`: Self { .alias(.default) }
		public static func inherited() -> Self { .value(.init()) }

		public var resolved: Common {
			switch self {
			case .alias(.default):
				return Common(defaultsFrom: .default)
			case let .value(value):
				return value
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			if let alias = try? container.decode(Alias.self) {
				self = .alias(alias)
			} else {
				self = .value(try Common(from: decoder))
			}
		}

		public func encode(to encoder: any Encoder) throws {
			if Manifest.encodeAliases, case let .alias(alias) = self {
				var container = encoder.singleValueContainer()
				try container.encode(alias)
			} else {
				try resolved.encode(to: encoder)
			}
		}

		public mutating func update(_ update: (inout Common) -> Void) {
			var value = resolved
			update(&value)
			self = .value(value)
		}

		func shouldEncode(relativeTo root: Root) -> Bool {
			if Manifest.encodeAliases, case .alias = self { return true }
			return resolved.hasDifferences(relativeTo: root)
		}

		mutating func inheritValues(
			movingFrom oldRoot: Root,
			to newRoot: Root
		) {
			guard case var .value(value) = self else { return }
			value.inheritValues(movingFrom: oldRoot, to: newRoot)
			self = .value(value)
		}
	}

	public enum CatalogResource: Codable, Equatable, Sendable {
		case alias(Alias)
		case value(Catalog)

		public static var `default`: Self { .alias(.default) }
		public static func inherited() -> Self { .value(.init()) }

		public var resolved: Catalog {
			switch self {
			case .alias(.default):
				return Catalog(defaultsFrom: .default)
			case let .value(value):
				return value
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			if let alias = try? container.decode(Alias.self) {
				self = .alias(alias)
			} else {
				self = .value(try Catalog(from: decoder))
			}
		}

		public func encode(to encoder: any Encoder) throws {
			if Manifest.encodeAliases, case let .alias(alias) = self {
				var container = encoder.singleValueContainer()
				try container.encode(alias)
			} else {
				try resolved.encode(to: encoder)
			}
		}

		public mutating func update(_ update: (inout Catalog) -> Void) {
			var value = resolved
			update(&value)
			self = .value(value)
		}

		func shouldEncode(relativeTo root: Root) -> Bool {
			if Manifest.encodeAliases, case .alias = self { return true }
			return resolved.hasDifferences(relativeTo: root)
		}

		mutating func inheritValues(
			movingFrom oldRoot: Root,
			to newRoot: Root
		) {
			guard case var .value(value) = self else { return }
			value.inheritValues(movingFrom: oldRoot, to: newRoot)
			self = .value(value)
		}
	}

	public enum XCStringsResource: Codable, Equatable, Sendable {
		case alias(Alias)
		case value(XCStrings)

		public static var `default`: Self { .alias(.default) }
		public static func inherited() -> Self { .value(.init()) }

		public var resolved: XCStrings {
			switch self {
			case .alias(.default):
				return XCStrings(defaultsFrom: .default)
			case let .value(value):
				return value
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			if let alias = try? container.decode(Alias.self) {
				self = .alias(alias)
			} else {
				self = .value(try XCStrings(from: decoder))
			}
		}

		public func encode(to encoder: any Encoder) throws {
			if Manifest.encodeAliases, case let .alias(alias) = self {
				var container = encoder.singleValueContainer()
				try container.encode(alias)
			} else {
				try resolved.encode(to: encoder)
			}
		}

		public mutating func update(_ update: (inout XCStrings) -> Void) {
			var value = resolved
			update(&value)
			self = .value(value)
		}

		func shouldEncode(relativeTo root: Root) -> Bool {
			if Manifest.encodeAliases, case .alias = self { return true }
			return resolved.hasDifferences(relativeTo: root)
		}

		mutating func inheritValues(
			movingFrom oldRoot: Root,
			to newRoot: Root
		) {
			guard case var .value(value) = self else { return }
			value.inheritValues(movingFrom: oldRoot, to: newRoot)
			self = .value(value)
		}
	}
}

private extension Manifest.FormatConfig.Common {
	init(defaultsFrom root: Manifest.FormatConfig.Root) {
		self.init(
			ignore: false,
			indentor: root.indentor,
			indentSize: root.indentSize,
			accessLevel: root.accessLevel,
			numbers: root.numbers,
			acronyms: root.acronyms
		)
	}
}

private extension Manifest.FormatConfig.Catalog {
	init(defaultsFrom root: Manifest.FormatConfig.Root) {
		self.init(
			ignore: false,
			indentor: root.indentor,
			indentSize: root.indentSize,
			accessLevel: root.accessLevel,
			numbers: root.numbers,
			acronyms: root.acronyms,
			groupByCatalogName: root.groupByCatalogName
		)
	}
}

private extension Manifest.FormatConfig.XCStrings {
	init(defaultsFrom root: Manifest.FormatConfig.Root) {
		self.init(
			ignore: false,
			indentor: root.indentor,
			indentSize: root.indentSize,
			accessLevel: root.accessLevel,
			numbers: root.numbers,
			acronyms: root.acronyms,
			groupByCatalogName: root.groupByCatalogName,
			splitByKeyPath: true
		)
	}
}
