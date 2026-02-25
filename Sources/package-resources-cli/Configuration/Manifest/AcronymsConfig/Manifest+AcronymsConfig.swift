import Casification

extension Manifest {
	public struct AcronymsConfig: Codable, Sendable {
		public static var current: Self { .init() }
		public static let `default`: Self = .init(
			processingPolicy: .default,
			values: ["default"]
		)

		public var processingPolicy: ProcessingPolicy
		public var values: [String]
		public var resolvedValues: Set<Substring> {
			func resolveValues(forAlias value: String) -> Set<Substring>? {
				switch value {
				case "default": .defaultAcronyms
				case "current": .currentAcronyms
				case "none": []
				default: nil
				}
			}

			var values = self.values.uniqued()
			var output: Set<Substring> = []
			while let alias = values.first, let resolved = resolveValues(forAlias: alias) {
				output.formUnion(resolved)
				values.removeFirst()
			}
			output.formUnion(Set(values.map { $0[...] }))
			return output
		}

		public init(
			processingPolicy: ProcessingPolicy = .current,
			values: [String] = ["current"]
		) {
			self.processingPolicy = processingPolicy
			self.values = values
		}

		public init(from decoder: any Decoder) throws {
			self = try decoder.decode { container in
				var values: [String] = []

				do {
					if let alias = try container.decodeIfPresent(String.self, forKey: "values") {
						values = [alias]
					} else {
						values = ["current"]
					}
				} catch {
					if let acronyms = try container.decodeIfPresent([String].self, forKey: "values"), !acronyms.isEmpty {
						values = acronyms
					} else {
						values = ["current"]
					}
				}

				return try AcronymsConfig(
					processingPolicy: container.decodeIfPresent("processing-policy").or(.current),
					values: values
				)
			}
		}

		public func encode(to encoder: any Encoder) throws {
			try encoder.encode { container in
				if Manifest.Version.current.major == 1 {
					try container.encode(processingPolicy, forKey: "acronyms-processing-policy")
					try container.encode(resolvedValues.sorted().map(String.init), forKey: "acronyms")

				} else {
					try container.encode(processingPolicy, forKey: "processing-policy")

					if !Manifest.encodeAliases {
						let codableValues = resolvedValues.sorted().map(String.init)
						try container.encode(codableValues, forKey: "values")
					} else {
						let uniquedValues = values.uniqued()
						if
							uniquedValues.count == 1,
							let value = uniquedValues.first,
							["current", "default", "none"].contains(value)
						{
							try container.encode(value, forKey: "values")
						} else {
							try container.encode(uniquedValues, forKey: "values")
						}
					}
				}
			}
		}
	}
}
