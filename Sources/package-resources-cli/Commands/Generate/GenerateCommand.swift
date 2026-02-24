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
		public var indentor: Manifest.Indentor? = nil

		@Option(
			name: .customLong("indent-size"),
			help: "Number of indentors per indentation level"
		)
		public var indentSize: Manifest.IndentSize? = nil

		@Option(
			name: .customLong("numbers-separator"),
			help: "Separator for numbers"
		)
		public var numbersSeparator: Manifest.NumbersConfig.Separator? = nil

		@Option(
			name: .customLong("numbers-next-token-mode"),
			help: "Processsing mode for a token after a number"
		)
		public var numbersNextTokenMode: Manifest.NumbersConfig.NextTokenMode? = nil

		@Option(
			name: .customLong("numbers-allowed-delimeters"),
			help: "Allowed delimeters for numbers"
		)
		public var numbersAllowedDelimeters: Manifest.NumbersConfig.AllowedDelimters? = nil

		@Option(
			name: .customLong("numbers-single-letter-boundary-options"),
			help: "Processsing mode for a token after a number"
		)
		public var numbersSingleLetterBoundaryOptions: [Manifest.NumbersConfig.SingleLetterBoundaryOption] = [.current]

		@Option(name: .customLong(
			"acronyms-processing-policy"),
			help: "Acronyms processing"
		)
		public var acronymsProcessingPolicy: Manifest.AcronymsConfig.ProcessingPolicy = .current

		@Option(
			name: .customLong("acronyms-values"),
			help: "Acronyms to be treated as a single character in camelCasing"
		)
		public var acronymsValues: [String] = ["current"]

		public func run() throws {
			let config = self.config.flatMap(Manifest.load(at:))
				.or(Manifest())
				.ifLet(output, override: \.output)
				.ifLet(indentor, override: \.indentor)
				.ifLet(indentSize, override: \.indentSize)
				.ifLet(
					numbersSeparator,
					override: \.numbers.separator
				)
				.ifLet(
					numbersNextTokenMode,
					override: \.numbers.nextTokenMode
				)
				.ifLet(
					numbersAllowedDelimeters,
					override: \.numbers.allowedDelimeters
				)
				.ifLet(
					.init(rawValue: numbersSingleLetterBoundaryOptions),
					override: \.numbers.singleLetterBoundaryOptions
				)
				.ifLet(
					acronymsProcessingPolicy,
					override: \.acronyms.processingPolicy
				)
				.ifLet(
					acronymsValues,
					override: \.acronyms.values
				)

			let outputPath = output ?? config.output ?? input.appending("/Resources.generated.swift")

			try withCasification({
				$0.camelCase.acronyms.processingPolicy = config.acronyms.processingPolicy.rawValue
				$0.camelCase.numbers.separator = config.numbers.separator.rawValue
				$0.camelCase.numbers.nextTokenMode = config.numbers.nextTokenMode.rawValue
				$0.common.numbers.allowedDelimeters = config.numbers.allowedDelimeters.rawValue
				$0.common.numbers.boundaryOptions = config.numbers.singleLetterBoundaryOptions.options
				$0.acronyms = config.acronyms.resolvedValues
			}) {
				let client = PackageResourcesClient(
					processResources: .standard(
						indentor: config.indentor.rawValue,
						indentSize: config.indentSize.rawValue
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
