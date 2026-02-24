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
		try encoder.encode { container in
			try key(["output"]) {
				try container.encodeIfPresent(output, forKey: $0.last!)
			}

			try key(["indentor"]) {
				try container.encodeIfPresent(indentor, forKey: $0.last!)
			}

			try key(["indent-size"]) {
				try container.encodeIfPresent(indentSize, forKey: $0.last!)
			}

			try key(["numbers"]) { k in
				try container.nested(k.last!) { container in
					try key(k + ["separator"]) {
						try container.encode(resolvedSeparator, forKey: $0.last!)
					}

					try key(k + ["allowed-delimeters"]) {
						try container.encode(commonNumbers.allowedDelimeters.map(String.init), forKey: $0.last!)
					}

					try key(k + ["next-token-mode"]) {
						try container.encode(camelCaseNumbers.nextTokenMode._config, forKey: $0.last!)
					}

					try key(k + ["single-letter-boundary-options"]) {
						try container.encode(
							commonNumbers.boundaryOptions
								.first(where: { $0._isDefaultSingleLetter })?
								.options._config,
							forKey: $0.last!
						)
					}
				}
			}

			try key(["acronyms"]) { k in
				try container.nested(k.last!) { container in
					try key(k + ["processing-policy"]) {
						try container.encode(
							camelCaseAcronyms.processingPolicy._config,
							forKey: $0.last!
						)
					}

					try key(k + ["values"]) {
						try container.encode(
							commonAcronyms.map(String.init).sorted(),
							forKey: $0.last!
						)
					}
			 }
			}
		}
	}

	private var resolvedIndentor: String {
		switch indentor {
		case "": return "tab"
		case "\t": return "tab"
		case " ": return "space"
		default: return indentor
		}
	}

	private var resolvedSeparator: String {
		switch camelCaseNumbers.separator {
		case "": return "none"
		default: return String(camelCaseNumbers.separator)
		}
	}
}

extension Manifest: Decodable {
	public init(from decoder: any Decoder) throws {
		self = try decoder.decode { container in
			var manifest = Manifest()

			let indentor: String = switch try container.decodeIfPresent(String.self, forKey: "indentor") {
			case .none: "\t"
			case "tab": "\t"
			case "space": " "
			case let .some(indentor): indentor
			}

			let indentSize: Int = try
			container.decodeIfPresent("indent-size")
			?? container.decodeIfPresent("tab-size")
			?? (indentor == " " ? 2 : 1)

			manifest.output = try container.decodeIfPresent("output")
			manifest.indentor = indentor
			manifest.indentSize = indentSize

			try container.nestedIfPresent("numbers") { container in
				try container.decodeIfPresent(
					String.self,
					forKey: "next-token-mode"
				)
				.flatMap { String.Casification.Configuration.CamelCase.Numbers.NextTokenMode(_config: $0) }
				.map { manifest.camelCaseNumbers.nextTokenMode = $0 }

				try container.decodeIfPresent(
					String.self,
					forKey: "separator"
				)
				.map { manifest.camelCaseNumbers.separator = $0[...] }

				try container.decodeIfPresent(
					[String].self,
					forKey: "allowed-delimeters"
				)
				.map { manifest.commonNumbers.allowedDelimeters = Set($0.compactMap(\.first)) }

				try container.decodeIfPresent(
					[String].self,
					forKey: "single-letter-boundary-options"
				).map {
					guard !$0.isEmpty else { return }
					manifest.commonNumbers.boundaryOptions = [.singleLetter(.init(_config: $0))]
				}
			}

			try container.nestedIfPresent("acronyms") { container in
				try container.decodeIfPresent(
					String.self,
					forKey: "processing-policy"
				)
				.flatMap { String.Casification.Configuration.CamelCase.Acronyms.ProcessingPolicy(_config: $0) }
				.map { manifest.camelCaseAcronyms.processingPolicy = $0 }

				try container.decodeIfPresent(
					[String].self,
					forKey: "values"
				)
				.map { manifest.commonAcronyms = Set($0.map { $0[...] }) }
			}

			return manifest
		}
	}
}

extension Manifest {
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

extension String.Casification.Configuration.NumericBoundaryOptions {
	init(_config options: [String]) {
		self = reduce([]) { result in
			for option in options {
				switch option {
				case "disable-separators":
					result.insert(.disableSeparators)
				case "disable-next-token-processing":
					result.insert(.disableNextTokenProcessing)
				case "enable-separators":
					result.remove(.disableSeparators)
				case "enable-next-token-processing":
					result.remove(.disableNextTokenProcessing)
				default:
					continue
				}
			}
		}
	}

	var _config: [String] {
		reduce([]) { output in
			if contains(.disableSeparators) {
				output.append("disable-separators")
			}
			if contains(.disableNextTokenProcessing) {
				output.append("disable-next-token-processing")
			}
		}
	}
}

extension String.Casification.Configuration.CamelCase.Numbers.NextTokenMode {
	init?(_config string: String) {
		switch string.case(.kebab) {
		case "default":
			self = .default
		case "current":
			self = .current
		case "inherit":
			self = .inherit
		case "automatic":
			self = .override(.automatic)
		case "camel":
			self = .override(.camel)
		case "pascal":
			self = .override(.pascal)
		default: return nil
		}
	}

	var _config: String {
		switch self {
		case .inherit: "inherit"
		case .override(.automatic): "automatic"
		case .override(.camel): "camel"
		case .override(.pascal): "pascal"
		}
	}
}

extension String.Casification.Configuration.CamelCase.Acronyms.ProcessingPolicy {
	init?(_config string: String) {
		switch string.case(.kebab) {
		case "default":
			self = .default
		case "current":
			self = .current
		case "preserve":
			self = .preserve
		case "always-match-case":
			self = .alwaysMatchCase
		case "always-capitalize":
			self = .alwaysCapitalize
		case "conditional-capitalization":
			self = .conditionalCapitalization
		default: return nil
		}
	}

	var _config: String {
		switch self {
		case .preserve: "preserve"
		case .alwaysMatchCase: "always-match-case"
		case .alwaysCapitalize: "always-capitalize"
		case .conditionalCapitalization: "conditional-capitalization"
		}
	}
}
