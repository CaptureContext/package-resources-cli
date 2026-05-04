@_spi(Internals) import Casification

extension Manifest: Encodable {
	@TaskLocal
	static var ignoredKeys: Set<[RawCodingKey]> = []

	@discardableResult
	func key<T>(
		_ value: [RawCodingKey],
		process: ([RawCodingKey]) throws -> T
	) rethrows -> T? {
		if Self.ignoredKeys.contains(value) { return nil }
		return try process(value)
	}

	public func encode(to encoder: any Encoder) throws {
		try Manifest.Version.$current.withValue(version) {
			try encoder.encode { container in
				try key(["version"]) {
					try container.encode(version, forKey: $0.last!)
				}
				
				try key(["output"]) {
					try container.encodeIfPresent(output, forKey: $0.last!)
				}
				
				try key(["indentor"]) {
					try container.encodeIfPresent(indentor, forKey: $0.last!)
				}
				
				try key(["indent-size"]) {
					if version.major == 1 {
						try container.encodeIfPresent(indentSize, forKey: "tab-size")
					} else {
						try container.encodeIfPresent(indentSize, forKey: $0.last!)
					}
				}

				try key(["access-level"]) {
					try container.encode(accessLevel, forKey: $0.last!)
				}

				try key(["group-xcstrings-by-catalog-name"]) {
					try container.encode(groupXCStringsByCatalogName, forKey: $0.last!)
				}

				try key(["resource-types"]) {
					try container.encode(resourceTypes, forKey: $0.last!)
				}
				
				try key(["numbers"]) { k in
					try container.encode(numbers, forKey: k.last!)
				}
				
				try key(["acronyms"]) { k in
					try container.encode(acronyms, forKey: k.last!)
				}
			}
		}
	}
}

extension Manifest: Decodable {
	public init(from decoder: any Decoder) throws {
		self = try decoder.decode { container in
			var manifest = Manifest()

			try manifest.ifLet(container.decodeIfPresent("version"), set: \.version)

			try Manifest.Version.$current.withValue(manifest.version) {
				let indentor: Indentor = try container.decodeIfPresent("indentor").or(.default)

				let indentSize: IndentSize = try Manifest.Indentor.$current.withValue(indentor) {
					try container.decodeIfPresent("indent-size")
						.or {
							let indentSize: IndentSize? = try container.decodeIfPresent("tab-size")

							if indentSize != nil, manifest.version.major > 1 {
								print(
									ANSI("⚠️ \"tab-size\" has been renamed to \"indent-size\"")
										.foreground(.yellow)
										.bold()
								)
							}

							return indentSize
						}
						.or(.default)
				}

				manifest.indentor = indentor
				manifest.indentSize = indentSize

				try manifest.ifLet(container.decodeIfPresent("output"), set: \.output)
				try manifest.ifLet(container.decodeIfPresent("access-level"), set: \.accessLevel)
				try manifest.ifLet(
					container.decodeIfPresent("group-xcstrings-by-catalog-name"),
					set: \.groupXCStringsByCatalogName
				)
				try manifest.ifLet(container.decodeIfPresent("resource-types"), set: \.resourceTypes)
				try manifest.ifLet(container.decodeIfPresent("numbers"), set: \.numbers)

				if manifest.version.major == 1 {
					try manifest.ifLet(
						container.decodeIfPresent("acronyms-processing-policy"),
						set: \.acronyms.processingPolicy
					)
					try manifest.ifLet(
						container.decodeIfPresent([String].self, forKey: "acronyms")?.uniqued(),
						set: \.acronyms.values
					)
				} else {
					try manifest.ifLet(container.decodeIfPresent("acronyms"), set: \.acronyms)
				}
			}

			return manifest
		}
	}
}
