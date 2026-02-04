import ArgumentParser
import Foundation
import Casification
import PackageResourcesClient
import Yams

// MARK: - Command

struct App: ParsableCommand {
	static let configuration: CommandConfiguration = .init(
		commandName: "package-resources-cli",
		abstract: "Code generator for https://github.com/capturecontext/swift-package-resources",
		version: "4.0.0",
		subcommands: [ConfigCommand.self, GenerateCommand.self]
	)
}

// MARK: - Config

extension App {
	public struct Config {
		typealias AcronymsProcessingPolicy = String.Casification.Modifiers.CamelCaseConfig.Acronyms.ProcessingPolicy

		public var output: String?
		public var indentor: String
		public var tabSize: Int
		public var acronymsProcessing: AcronymsProcessingPolicy
		public var acronyms: Set<Substring>

		public init(
			output: String? = nil,
			indentor: String,
			tabSize: Int,
			acronymsProcessing: AcronymsProcessingPolicy,
			acronyms: Set<Substring>
		) {
			self.output = output
			self.indentor = indentor
			self.tabSize = tabSize
			self.acronymsProcessing = acronymsProcessing
			self.acronyms = acronyms
		}

		public func asCodable() -> CodableConfig {
			.init(
				output: output,
				indentor: indentor,
				tabSize: tabSize,
				acronymsProcessing: acronymsProcessing.description,
				acronyms: acronyms.map(String.init).sorted()
			)
		}

		public func applying(_ codable: App.CodableConfig) -> Self {
			.init(
				output: codable.output ?? self.output,
				indentor: codable.indentor ?? self.indentor,
				tabSize: codable.tabSize ?? self.tabSize,
				acronymsProcessing: codable.acronymsProcessing.flatMap(AcronymsProcessingPolicy.init) ?? .default,
				acronyms: codable.acronyms.map { Set($0.map { $0[...] }) } ?? self.acronyms
			)
		}

		public static var `default`: Self {
			return .init(
				indentor: "\t",
				tabSize: 1,
				acronymsProcessing: .default,
				acronyms: .standardAcronyms
			)
		}
	}

	public struct CodableConfig: Codable {
		enum Format {
			case yaml
			case json
		}

		public var output: String?
		public var indentor: String?
		public var tabSize: Int?
		public var acronymsProcessing: String?
		public var acronyms: [String]?

		public init(
			output: String? = nil,
			indentor: String? = nil,
			tabSize: Int? = nil,
			acronymsProcessing: String? = nil,
			acronyms: [String]? = nil
		) {
			self.output = output
			self.indentor = indentor
			self.tabSize = tabSize
			self.acronymsProcessing = acronymsProcessing
			self.acronyms = acronyms
		}

		public enum CodingKeys: String, CodingKey {
			case output
			case indentor
			case tabSize = "tab-size"
			case acronymsProcessing = "acronyms-processing"
			case acronyms
		}

		func ifLet<T>(
			_ value: T?,
			override keyPath: WritableKeyPath<Self, T?>
		) -> Self {
			guard let value else { return self }
			var copy = self
			copy[keyPath: keyPath] = value
			return copy
		}

		static func load(at path: String) -> Self? {
			loadWithFormat(at: path)?.config
		}

		static func loadWithFormat(at path: String) -> (config: Self, format: Format)? {
			guard FileManager.default.fileExists(atPath: path)
			else { return nil }

			let url = URL(fileURLWithPath: path)

			guard let data = try? Data(contentsOf: url)
			else { return nil }

			typealias Decode = () throws -> (Self, Format)
			let decodeJSON: Decode = { try (JSONDecoder().decode(Self.self, from: data), .json) }
			let decodeYAML: Decode = { try (YAMLDecoder().decode(Self.self, from: data), .yaml) }

			if url.pathExtension == "json" {
				return (try? decodeJSON()) ?? (try? decodeYAML())
			} else {
				return (try? decodeYAML()) ?? (try? decodeJSON())
			}
		}
	}
}

extension App.Config.AcronymsProcessingPolicy: @retroactive CustomStringConvertible {
	init?(_ string: String) {
		switch string.case(.kebab) {
		case "default":
			self = .default
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

	public var description: String {
		switch self {
		case .preserve: "preserve"
		case .alwaysMatchCase: "always-match-case"
		case .alwaysCapitalize: "always-capitalize"
		case .conditionalCapitalization: "conditional-capitalization"
		}
	}
}
