import Casification
import SystemConfiguration

public struct Manifest {

	public var output: String?
	public var indentor: String
	public var indentSize: Int

	public var camelCaseNumbers: CamelCaseConfig.Numbers
	public var camelCaseAcronyms: CamelCaseConfig.Acronyms
	public var commonNumbers: CommonCaseConfig.Numbers
	public var commonAcronyms: Set<Substring>

	public init(
		output: String? = nil,
		indentor: String = "\t",
		indentSize: Int = 1,
		camelCaseNumbers: CamelCaseConfig.Numbers = .current,
		camelCaseAcronyms: CamelCaseConfig.Acronyms = .current,
		commonNumbers: CommonCaseConfig.Numbers = .current,
		commonAcronyms: Set<Substring> = .currentAcronyms
	) {
		self.output = output
		self.indentor = indentor
		self.indentSize = indentSize
		self.camelCaseNumbers = camelCaseNumbers
		self.camelCaseAcronyms = camelCaseAcronyms
		self.commonNumbers = commonNumbers
		self.commonAcronyms = commonAcronyms
	}
}
