@_spi(Internals) import Casification

extension Manifest: Encodable {
	@TaskLocal
	@_spi(Internals)
	public static var ignoredKeys: Set<[RawCodingKey]> = []

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
			if version.major >= 4 {
				try encodeV4(to: encoder)
			} else {
				try encodeLegacy(to: encoder)
			}
		}
	}

	private func encodeV4(to encoder: any Encoder) throws {
		try encoder.encode { container in
			try key(["version"]) {
				try container.encode(version, forKey: $0.last!)
			}

			try key(["output"]) {
				try container.encodeIfPresent(output, forKey: $0.last!)
			}

			try Manifest.FormatConfig.$root.withValue(format.root) {
				try encodeRoot(format.root, to: &container)

				try key(["colors"]) {
					if format.colors.shouldEncode(relativeTo: format.root) {
						try container.encode(format.colors, forKey: $0.last!)
					}
				}

				try key(["images"]) {
					if format.images.shouldEncode(relativeTo: format.root) {
						try container.encode(format.images, forKey: $0.last!)
					}
				}

				try key(["fonts"]) {
					if format.fonts.shouldEncode(relativeTo: format.root) {
						try container.encode(format.fonts, forKey: $0.last!)
					}
				}

				try key(["nibs"]) {
					if format.nibs.shouldEncode(relativeTo: format.root) {
						try container.encode(format.nibs, forKey: $0.last!)
					}
				}

				try key(["storyboards"]) {
					if format.storyboards.shouldEncode(relativeTo: format.root) {
						try container.encode(format.storyboards, forKey: $0.last!)
					}
				}

				try key(["xcstrings"]) {
					if format.xcStrings.shouldEncode(relativeTo: format.root) {
						try container.encode(format.xcStrings, forKey: $0.last!)
					}
				}
			}
		}
	}

	private func encodeLegacy(to encoder: any Encoder) throws {
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

			try key(["indent-size"]) { key in
				try Manifest.Indentor.$current.withValue(indentor) {
					if version.major == 1 {
						try container.encodeIfPresent(indentSize, forKey: "tab-size")
					} else {
						try container.encodeIfPresent(indentSize, forKey: key.last!)
					}
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

			if version.major == 1 {
				try key(["acronyms-processing-policy"]) { k in
					try container.encode(acronyms.processingPolicy, forKey: k.last!)
				}

				try key(["acronyms"]) { k in
					try container.encode(
						acronyms.resolvedValues.sorted().map(String.init),
						forKey: k.last!
					)
				}
			} else {
				try key(["acronyms"]) { k in
					try container.encode(acronyms, forKey: k.last!)
				}
			}
		}
	}

	private func encodeRoot(
		_ root: FormatConfig.Root,
		to container: inout KeyedEncodingContainer<RawCodingKey>
	) throws {
		try key(["indentor"]) {
			try container.encode(root.indentor, forKey: $0.last!)
		}

		try key(["indent-size"]) { key in
			try Manifest.Indentor.$current.withValue(root.indentor) {
				try container.encode(root.indentSize, forKey: key.last!)
			}
		}

		try key(["access-level"]) {
			try container.encode(root.accessLevel, forKey: $0.last!)
		}

		try key(["group-by-catalog"]) {
			try container.encode(root.groupByCatalogName, forKey: $0.last!)
		}

		try key(["numbers"]) {
			try container.encode(root.numbers, forKey: $0.last!)
		}

		try key(["acronyms"]) {
			try container.encode(root.acronyms, forKey: $0.last!)
		}
	}
}

extension Manifest: Decodable {
	public init(from decoder: any Decoder) throws {
		self = try decoder.decode { container in
			let decodedVersion: Version? = try container.decodeIfPresent("version")
			let version = decodedVersion ?? inferredDefaultVersion(from: container)

			return try Manifest.Version.$current.withValue(version) {
				if version.major >= 4 {
					try decodeV4(from: container, version: version)
				} else {
					try decodeLegacy(from: container, version: version)
				}
			}
		}
	}
}

private func inferredDefaultVersion(
	from container: KeyedDecodingContainer<RawCodingKey>
) -> Manifest.Version {
	let legacyKeys: [RawCodingKey] = [
		"resource-types",
		"group-xcstrings-by-catalog-name",
		"tab-size",
	]

	if legacyKeys.contains(where: { container.hasEquivalent(for: $0) }) {
		return .init(major: 3)
	}

	return .init(major: 4)
}

private func decodeV4(
	from container: KeyedDecodingContainer<RawCodingKey>,
	version: Manifest.Version
) throws -> Manifest {
	let root = try decodeRoot(from: container, version: version)
	let format = try Manifest.FormatConfig.$root.withValue(root) {
		try Manifest.FormatConfig(
			root: root,
			colors: container.decodeIfPresent("colors"),
			images: container.decodeIfPresent("images"),
			fonts: container.decodeIfPresent("fonts"),
			nibs: container.decodeIfPresent("nibs"),
			storyboards: container.decodeIfPresent("storyboards"),
			xcStrings: container.decodeIfPresent("xcstrings")
		)
	}

	return try Manifest(
		version: version,
		output: container.decodeIfPresent("output"),
		format: format,
		resourceTypes: .default
	)
}

private func decodeLegacy(
	from container: KeyedDecodingContainer<RawCodingKey>,
	version: Manifest.Version
) throws -> Manifest {
	var manifest = Manifest(version: version)
	let root = try decodeRoot(from: container, version: version)
	manifest.format = .init(root: root)

	try manifest.ifLet(container.decodeIfPresent("output"), set: \.output)
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

	return manifest
}

private func decodeRoot(
	from container: KeyedDecodingContainer<RawCodingKey>,
	version: Manifest.Version
) throws -> Manifest.FormatConfig.Root {
	let indentor: Manifest.Indentor = try container.decodeIfPresent("indentor")
		.or(.default)

	let indentSize: Manifest.IndentSize = try Manifest.Indentor.$current.withValue(indentor) {
		try container.decodeIfPresent("indent-size")
			.or {
				let indentSize: Manifest.IndentSize? = try container.decodeIfPresent("tab-size")

				if indentSize != nil, version.major > 1 {
					print("⚠️ \"tab-size\" has been renamed to \"indent-size\"")
				}

				return indentSize
			}
			.or(.default)
	}

	return try Manifest.FormatConfig.Root(
		indentor: indentor,
		indentSize: indentSize,
		accessLevel: container.decodeIfPresent("access-level").or(.default),
		numbers: container.decodeIfPresent("numbers").or(.default),
		acronyms: decodeRootAcronyms(from: container, version: version),
		groupByCatalogName: container.decodeIfPresent("group-by-catalog").or(true)
	)
}

private func decodeRootAcronyms(
	from container: KeyedDecodingContainer<RawCodingKey>,
	version: Manifest.Version
) throws -> Manifest.AcronymsConfig {
	if version.major == 1 {
		var acronyms = Manifest.AcronymsConfig.default
		acronyms.processingPolicy = try container
			.decodeIfPresent("acronyms-processing-policy")
			.or(acronyms.processingPolicy)
		let values = try container
			.decodeIfPresent([String].self, forKey: "acronyms")?
			.uniqued()
		acronyms.values = values.or(acronyms.values)
		return acronyms
	}

	return try container.decodeIfPresent("acronyms").or(.default)
}
