import ArgumentParser
import Foundation
import Casification
import PackageResourcesClient
import Yams

extension App {
	struct GenerateCommand: ParsableCommand {
		static let configuration: CommandConfiguration = .init(
			commandName: "generate",
			abstract: "Generates boilerplate for package resources"
		)

		init() {}

		init(
			input: String,
			config: String? = nil,
			output: String? = nil,
			indentor: String? = nil,
			tabSize: Int? = nil
		) {
			self.input = input
			self.config = config
			self.output = output
			self.indentor = indentor
			self.tabSize = tabSize
		}

		@Option(name: .shortAndLong, help: "Path to root directory for scanning.", transform: { $0 })
		public var input: String = "./"

		@Option(name: .shortAndLong, help: "Path to configuration file")
		public var config: String? = nil

		@Option(name: .shortAndLong, help: "Path to output file")
		public var output: String? = nil

		@Option(name: .long, help: "Indentation character")
		public var indentor: String? = nil

		@Option(name: .customLong("tab-size"), help: "Tab size")
		public var tabSize: Int? = nil

		@Option(name: .customLong("acronyms-processing"), help: "Acronyms processing")
		public var acronymsProcessing: String? = nil

		@Option(name: .long, help: "Acronyms to be treated as a single character in camelCasing")
		public var acronyms: [String] = []

		public func run() throws {
			var decodedConfig: App.CodableConfig = self.config.flatMap(App.CodableConfig.load(at:)) ?? .init()

			do {
				decodedConfig = decodedConfig
					.ifLet(output, override: \.output)
					.ifLet(indentor, override: \.indentor)
					.ifLet(tabSize, override: \.tabSize)
					.ifLet(acronymsProcessing, override: \.acronymsProcessing)

				if !acronyms.isEmpty {
					decodedConfig.acronyms = acronyms
				}
			}

			let outputPath = output ?? decodedConfig.output ?? input.appending("/Resources.generated.swift")
			let config = App.Config.default.applying(decodedConfig)

			let client = PackageResourcesClient(
				processResources: .standard(
					tabSize: config.tabSize,
					indentor: config.indentor,
					acronyms: .init(
						reservedValues: config.acronyms,
						processingPolicy: config.acronymsProcessing
					)
				)
			)

			try client.processResources(atPath: input, toFileAtPath: outputPath).get()
		}
	}
}
