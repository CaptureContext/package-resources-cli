import Dependencies
import PackageResourcesCore
import FunctionComposition
import PackageResourcesFS
import Foundation
import Snippets
import SwiftSnippets

public protocol PackageResourcesClient: Sendable {
	func processResources(
		for resourceTypes: EnabledResourceTypes,
		atPath path: String
	) async -> String

	func processResources(
		for resourceTypes: EnabledResourceTypes,
		atPath path: String,
		into outputFilePath: String
	) async throws
}

public struct EnabledResourceTypes: Equatable, OptionSet, Sendable {
	public var rawValue: UInt32

	public init(rawValue: UInt32) {
		self.rawValue = rawValue
	}

	public static var colors: Self { .init(rawValue: 1 << 0) }
	public static var fonts: Self { .init(rawValue: 1 << 1) }
	public static var images: Self { .init(rawValue: 1 << 2) }
	public static var nibs: Self { .init(rawValue: 1 << 3) }
	public static var storyboards: Self { .init(rawValue: 1 << 4) }
	public static var xcStrings: Self { .init(rawValue: 1 << 5) }
	public static var interfaceBuilder: Self { [.nibs, .storyboards] }
	public static var all: Self {
		[
			.colors, .fonts, .images,
			.nibs, .storyboards, .xcStrings
		]
	}
}

internal struct PackageResourcesClientImpl: PackageResourcesClient {
	func processResources(
		for resourceTypes: EnabledResourceTypes,
		atPath path: String,
		into outputFilePath: String
	) async throws {
		let outputFile = try File(path: outputFilePath, create: true)

		@Dependency(\.generatedResourcesDisclaimerProvider)
		var disclaimer

		let processed = try await processResourcesThrowing(
			for: resourceTypes,
			atPath: path
		)

		let output = renderPackageResourceSnippet(
			Snippets.Join(String.const(.newlines(2))) {
				if let disclaimer = disclaimer(outputFile.name) {
					disclaimer
				}
				processed
			}
			.skipEmpty()
		)

		try outputFile.write(output)
	}

	func processResources(
		for resourceTypes: EnabledResourceTypes,
		atPath path: String,
	) async -> String {
		let processors = processors(for: resourceTypes)
		var results = Array<String?>(repeating: nil, count: processors.count)

		await withTaskGroup(of: (Int, String?).self) { group in
			for (index, processor) in processors.enumerated() {
				group.addTask {
					@Dependency(\.resourceFormatConfig)
					var resourceFormatConfig

					let result = withErrorReporting {
						try resourceFormatConfig.withFormat(for: processor.kind) {
							try processor.run(path)
						}
					}
					return (index, result)
				}
			}

			for await (index, result) in group {
				results[index] = result
			}
		}

		return renderResults(results)
	}

	private func processResourcesThrowing(
		for resourceTypes: EnabledResourceTypes,
		atPath path: String,
	) async throws -> String {
		let processors = processors(for: resourceTypes)
		var results = Array<String?>(repeating: nil, count: processors.count)

		try await withThrowingTaskGroup(of: (Int, String).self) { group in
			for (index, processor) in processors.enumerated() {
				group.addTask {
					@Dependency(\.resourceFormatConfig)
					var resourceFormatConfig

					return try (
						index,
						resourceFormatConfig.withFormat(for: processor.kind) {
							try processor.run(path)
						}
					)
				}
			}

			for try await (index, result) in group {
				results[index] = result
			}
		}

		return renderResults(results)
	}

	private func processors(
		for resourceTypes: EnabledResourceTypes
	) -> [ResourceProcessor] {
		var processors: [ResourceProcessor] = []

		if resourceTypes.contains(.colors) {
			@Dependency(KeyPath.processResources(of: PackageResources.Color.self))
			var processor

			processors.append(.init(kind: .colors, run: processor))
		}

		if resourceTypes.contains(.images) {
			@Dependency(KeyPath.processResources(of: PackageResources.Image.self))
			var processor

			processors.append(.init(kind: .images, run: processor))
		}

		if resourceTypes.contains(.storyboards) {
			@Dependency(KeyPath.processResources(of: PackageResources.Storyboard.self))
			var processor

			processors.append(.init(kind: .storyboards, run: processor))
		}

		if resourceTypes.contains(.nibs) {
			@Dependency(KeyPath.processResources(of: PackageResources.Nib.self))
			var processor

			processors.append(.init(kind: .nibs, run: processor))
		}

		if resourceTypes.contains(.fonts) {
			@Dependency(KeyPath.processResources(of: PackageResources.Font.self))
			var processor

			processors.append(.init(kind: .fonts, run: processor))
		}

		if resourceTypes.contains(.xcStrings) {
			@Dependency(KeyPath.processResources(of: PackageResources.LocalizedString.self))
			var processor

			processors.append(.init(kind: .xcStrings, run: processor))
		}

		return processors
	}

	private func renderResults(_ results: [String?]) -> String {
		let imports = """
		import Foundation
		import PackageResourcesCore
		"""
		let renderedResults = results
			.compactMap { $0 }
			.filter { !$0.isEmpty }
			.joined(separator: "\n\n")

		return renderPackageResourceSnippet(
			Snippets.Join(String.const(.newlines(2))) {
				imports
				renderedResults
			}
			.skipEmpty()
		) + "\n"
	}
}

private struct ResourceProcessor: Sendable {
	var kind: ResourceFormatConfig.ResourceKind
	var run: SendableSyncThrowingFunc<String, String, Error>
}

extension DependencyValues {
	private enum PackageResourcesClientKey: DependencyKey {
		static var liveValue: any PackageResourcesClient { PackageResourcesClientImpl() }
		static var testValue: any PackageResourcesClient { PackageResourcesClientImpl() }
	}

	public var packageResourcesClient: any PackageResourcesClient {
		get { self[PackageResourcesClientKey.self] }
		set { self[PackageResourcesClientKey.self] = newValue }
	}
}
