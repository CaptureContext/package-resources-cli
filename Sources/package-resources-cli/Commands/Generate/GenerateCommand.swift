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
			indentSize: Int? = nil
		) {
			self.input = input
			self.config = config
			self.output = output
			self.indentor = indentor
			self.indentSize = indentSize
		}

		@Option(
			name: .shortAndLong, help: "Path to root directory for scanning.",
			transform: { $0 }
		)
		public var input: String = "./"

		@Option(
			name: .shortAndLong,
			help: "Path to configuration file"
		)
		public var config: String? = nil

		@Option(
			name: .shortAndLong,
			help: "Path to output file"
		)
		public var output: String? = nil

		@Option(
			name: .long,
			help: "Indentation character"
		)
		public var indentor: String? = nil

		@Option(
			name: .customLong("indent-size"),
			help: "Tab size"
		)
		public var indentSize: Int? = nil

		@Option(
			name: .customLong("numbers-next-token-mode"),
			help: "Processsing mode for a token after a number"
		)
		public var numbersNextTokenMode: String? = nil

		@Option(
			name: .customLong("numbers-separator"),
			help: "Separator for numbers"
		)
		public var numbersSeparator: String? = nil

		@Option(
			name: .customLong("numbers-allowed-delimeters"),
			help: "Allowed delimeters for numbers"
		)
		public var numbersAllowedDelimeters: String? = nil

		@Option(
			name: .customLong("numbers-single-letter-boundary-options"),
			help: "Processsing mode for a token after a number"
		)
		public var numbersSingleLetterBoundaryOptions: [String] = [._unspecified]

		@Option(name: .customLong(
			"acronyms-processing"),
			help: "Acronyms processing"
		)
		public var acronymsProcessing: String? = nil

		@Option(
			name: .customLong("acronyms-values"),
			help: "Acronyms to be treated as a single character in camelCasing"
		)
		public var acronymsValues: [String] = [._unspecified]

		public func run() throws {
			let config = self.config.flatMap(Manifest.load(at:))
				.or(.init())
				.ifLet(output, override: \.output)
				.ifLet(indentor, override: \.indentor)
				.ifLet(indentSize, override: \.indentSize)
				.ifLet(
					numbersNextTokenMode.flatMap { .init(_config: $0) },
					override: \.camelCaseNumbers.nextTokenMode
				)
				.ifLet(
					numbersSeparator.map { $0[...] },
					override: \.camelCaseNumbers.separator
				)
				.ifLet(
					numbersAllowedDelimeters.map { Set($0) },
					override: \.commonNumbers.allowedDelimeters
				)
				.ifLet(
					numbersSingleLetterBoundaryOptions == [._unspecified] ? nil : [
						.singleLetter(.init(_config: numbersSingleLetterBoundaryOptions))
					],
					override: \.commonNumbers.boundaryOptions
				)
				.ifLet(
					acronymsProcessing.flatMap { .init(_config: $0) },
					override: \.camelCaseAcronyms.processingPolicy
				)
				.ifLet(
					acronymsValues == [._unspecified] ? nil : Set(acronymsValues.map { $0[...] }),
					override: \.commonAcronyms
				)

			let outputPath = output ?? config.output ?? input.appending("/Resources.generated.swift")

			try withCasification({
				$0.camelCase.acronyms.processingPolicy = config.camelCaseAcronyms.processingPolicy
				$0.camelCase.numbers.separator = config.camelCaseNumbers.separator
				$0.camelCase.numbers.nextTokenMode = config.camelCaseNumbers.nextTokenMode
				$0.common.numbers.allowedDelimeters = config.commonNumbers.allowedDelimeters
				$0.common.numbers.boundaryOptions = config.commonNumbers.boundaryOptions
				$0.acronyms = config.commonAcronyms
			}) {
				let client = PackageResourcesClient(
					processResources: .standard(
						indentor: config.indentor,
						indentSize: config.indentSize
					)
				)

				try client.processResources(
					atPath: input,
					toFileAtPath: outputPath
				).get()

				print(
					ANSI("✅ Successfully generated package resources")
						.foreground(.green)
						.bold()
				)
			}
		}
	}
}
