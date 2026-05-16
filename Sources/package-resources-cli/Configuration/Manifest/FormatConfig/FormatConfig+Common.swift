extension Manifest.FormatConfig {
	@TaskLocal
	static var common: Common = .init()

	public struct Common {
		public var indentor: Manifest.Indentor
		public var indentSize: Manifest.IndentSize
		public var accessLevel: Manifest.AccessLevelConfig
		public var numbers: Manifest.NumbersConfig
		public var acronyms: Manifest.AcronymsConfig

		public init(
			indentor: Manifest.Indentor = Manifest.FormatConfig.root.indentor,
			indentSize: Manifest.IndentSize = Manifest.FormatConfig.root.indentSize,
			accessLevel: Manifest.AccessLevelConfig = Manifest.FormatConfig.root.accessLevel,
			numbers: Manifest.NumbersConfig = Manifest.FormatConfig.root.numbers,
			acronyms: Manifest.AcronymsConfig = Manifest.FormatConfig.root.acronyms,
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
