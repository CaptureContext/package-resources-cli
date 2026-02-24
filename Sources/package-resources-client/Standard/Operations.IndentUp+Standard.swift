extension PackageResourcesClient.Operations.IndentUp {
	public static func standard(indentor: String = "\t", indentSize: Int = 1) -> Self {
		let _indentor = String(repeating: indentor, count: indentSize)
		return .init { level in
			return { source in
				source.components(separatedBy: .newlines)
					.map { String(repeating: _indentor, count: level) + $0 }
					.joined(separator: "\n")
			}
		}
	}
}
