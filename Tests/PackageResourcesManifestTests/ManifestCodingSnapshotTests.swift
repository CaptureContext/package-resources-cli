@_spi(Internals) @testable import PackageResourcesManifest

import SnapshotTesting
import Testing
import Yams

@Suite
struct ManifestCodingSnapshotTests {
	@Test
	func v4AliasesAndInheritanceEncoding() throws {
		let manifest = try YAMLDecoder().decode(
			Manifest.self,
			from: v4AliasesAndInheritanceYAML
		)

		let yaml = try Manifest.$encodeAliases.withValue(true) {
			try YAMLEncoder().encode(manifest)
		}

		assertSnapshot(of: yaml, as: .yaml, named: "default")
	}

	@Test
	func v4ResolvedEncoding() throws {
		let manifest = try YAMLDecoder().decode(
			Manifest.self,
			from: v4AliasesAndInheritanceYAML
		)

		let yaml = try YAMLEncoder().encode(manifest)

		assertSnapshot(of: yaml, as: .yaml, named: "default")
	}

	@Test
	func v3LegacyResourceTypesEncoding() throws {
		let manifest = try YAMLDecoder().decode(
			Manifest.self,
			from: """
			version: "3.0"
			indentor: whitespace
			indent-size: 4
			access-level: public
			resource-types:
			  - images
			group-xcstrings-by-catalog-name: false
			"""
		)

		let yaml = try Manifest.$encodeAliases.withValue(true) {
			try YAMLEncoder().encode(manifest)
		}

		assertSnapshot(of: yaml, as: .yaml, named: "default")
	}

	@Test
	func v1LegacyAcronymsEncoding() throws {
		let manifest = try YAMLDecoder().decode(
			Manifest.self,
			from: """
			version: "1.0"
			indentor: whitespace
			tab-size: 3
			access-level: internal
			acronyms-processing-policy: preserve
			acronyms:
			  - URL
			  - ID
			"""
		)

		let yaml = try YAMLEncoder().encode(manifest)

		assertSnapshot(of: yaml, as: .yaml, named: "default")
	}

	private var v4AliasesAndInheritanceYAML: String {
		"""
		version: "4.0"
		indentor: whitespace
		group-by-catalog: false
		images: default
		colors:
		  ignore: true
		  group-by-folders: false
		  split-by-key-path: false
		scn-scenes:
		  ignore: true
		  group-by-folders: false
		  split-by-key-path: false
		xcstrings:
		  split-by-key-path: false
		"""
	}
}
