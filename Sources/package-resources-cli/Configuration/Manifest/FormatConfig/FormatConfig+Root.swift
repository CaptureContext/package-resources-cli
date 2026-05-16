extension Manifest.FormatConfig {
	@TaskLocal
	static var root: Root = .init()

	public struct Root {
		public var indentor: Manifest.Indentor
		public var indentSize: Manifest.IndentSize
		public var accessLevel: Manifest.AccessLevelConfig
		public var numbers: Manifest.NumbersConfig
		public var acronyms: Manifest.AcronymsConfig
		public var groupByCatalogName: Bool?

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
}
