@_spi(Internals) @testable import PackageResourcesManifest

import CustomDump
import PackageResourcesClient
import Testing
import Yams

@Suite
struct ManifestV4Tests {
	@Test
	func defaultManifestVersionIsV4() {
		expectNoDifference(4, Manifest().version.major)
	}

	@Test
	func decodesRootInheritanceResourceOverridesAliasesAndIgnore() throws {
		let manifest = try YAMLDecoder().decode(
			Manifest.self,
			from: """
			version: "4.0"
			indentor: whitespace
			group-by-catalog: false
			images: default
			colors:
			  ignore: true
			  group-by-folders: false
			  split-by-key-path: false
			xcstrings:
			  split-by-key-path: false
			"""
		)

		expectNoDifference(4, manifest.version.major)
		expectNoDifference("whitespace", manifest.format.root.indentor.description)
		expectNoDifference(false, manifest.format.root.groupByCatalogName)
		expectNoDifference(true, manifest.format.colors.resolved.ignore)
		expectNoDifference(false, manifest.format.colors.resolved.groupByFolders)
		expectNoDifference(false, manifest.format.colors.resolved.splitByKeyPath)
		expectNoDifference(false, manifest.enabledResourceTypes.contains(.colors))
		expectNoDifference(true, manifest.enabledResourceTypes.contains(.images))
		expectNoDifference("default", manifest.format.images.resolved.indentor.description)
		expectNoDifference(true, manifest.format.images.resolved.groupByCatalogName)
		expectNoDifference(true, manifest.format.images.resolved.groupByFolders)
		expectNoDifference(true, manifest.format.images.resolved.splitByKeyPath)
		expectNoDifference(false, manifest.format.xcStrings.resolved.splitByKeyPath)

		if case .alias(.default) = manifest.format.images {
		} else {
			Issue.record("Expected images to decode as the default format alias.")
		}
	}

	@Test
	func v4IgnoresLegacyResourceTypesForEnabledResources() throws {
		let manifest = try YAMLDecoder().decode(
			Manifest.self,
			from: """
			version: "4.0"
			resource-types: none
			images:
			  ignore: true
			"""
		)

		expectNoDifference(false, manifest.enabledResourceTypes.contains(.images))
		expectNoDifference(true, manifest.enabledResourceTypes.contains(.colors))
		expectNoDifference(true, manifest.enabledResourceTypes.contains(.xcStrings))
	}

	@Test
	func decodesAssetCatalogSpecificKeysAndMapsToRuntimeConfig() throws {
		let manifest = try YAMLDecoder().decode(
			Manifest.self,
			from: """
			version: "4.0"
			colors:
			  group-by-folders: false
			  split-by-key-path: false
			images:
			  group-by-folders: false
			  split-by-key-path: false
			"""
		)

		expectNoDifference(false, manifest.format.colors.resolved.groupByFolders)
		expectNoDifference(false, manifest.format.colors.resolved.splitByKeyPath)
		expectNoDifference(false, manifest.format.images.resolved.groupByFolders)
		expectNoDifference(false, manifest.format.images.resolved.splitByKeyPath)

		let runtimeConfig = manifest.format.resourceFormatConfig
		expectNoDifference(false, runtimeConfig.resolved(for: .colors).groupByFolders)
		expectNoDifference(false, runtimeConfig.resolved(for: .colors).splitByKeyPath)
		expectNoDifference(false, runtimeConfig.resolved(for: .images).groupByFolders)
		expectNoDifference(false, runtimeConfig.resolved(for: .images).splitByKeyPath)
	}

	@Test
	func encodesAliasesWhenRequestedAndOmitsResourceTypesForV4() throws {
		let manifest = Manifest(
			format: .init(
				root: .init(
					indentor: .whitespace,
					groupByCatalogName: false
				),
				colors: .value(.init(
					ignore: true,
					groupByFolders: false,
					splitByKeyPath: false
				)),
				images: .default
			)
		)

		let yaml = try Manifest.$encodeAliases.withValue(true) {
			try YAMLEncoder().encode(manifest)
		}

		expectNoDifference(true, yaml.contains("images: default"))
		expectNoDifference(true, yaml.contains("group-by-catalog: false"))
		expectNoDifference(true, yaml.contains("ignore: true"))
		expectNoDifference(true, yaml.contains("group-by-folders: false"))
		expectNoDifference(true, yaml.contains("split-by-key-path: false"))
		expectNoDifference(false, yaml.contains("resource-types"))
	}

	@Test
	func encodesResolvedFormatSectionsWhenAliasesAreDisabled() throws {
		let manifest = Manifest(
			format: .init(
				root: .init(
					indentor: .whitespace,
					groupByCatalogName: false
				),
				images: .default
			)
		)

		let yaml = try YAMLEncoder().encode(manifest)

		expectNoDifference(true, yaml.contains("images:"))
		expectNoDifference(false, yaml.contains("images: default"))
		expectNoDifference(true, yaml.contains("group-by-catalog: true"))
		expectNoDifference(false, yaml.contains("resource-types"))
	}

	@Test
	func decodesLegacyResourceTypesAndXCStringsGrouping() throws {
		let manifest = try YAMLDecoder().decode(
			Manifest.self,
			from: """
			version: "3.0"
			resource-types:
			  - images
			group-xcstrings-by-catalog-name: false
			"""
		)

		expectNoDifference(3, manifest.version.major)
		expectNoDifference(EnabledResourceTypes.images, manifest.enabledResourceTypes)
		expectNoDifference(false, manifest.groupXCStringsByCatalogName)
	}

	@Test
	func resourceFormatConfigUsesResourceSpecificResolvedIndentation() {
		let format = Manifest.FormatConfig(
			root: .init(indentor: .whitespace),
			images: .default
		)

		expectNoDifference("  ", format.resourceFormatConfig.resolved(for: nil).indentor)
		expectNoDifference("\t", format.resourceFormatConfig.resolved(for: .images).indentor)
		expectNoDifference(true, format.resourceFormatConfig.resolved(for: .images).groupByFolders)
		expectNoDifference(true, format.resourceFormatConfig.resolved(for: .images).splitByKeyPath)
	}
}
