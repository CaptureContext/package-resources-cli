import Casification
import PackageResourcesClient

extension Manifest.FormatConfig {
	public var resourceFormatConfig: ResourceFormatConfig {
		let rootCommon = makeCommon(root)

		return ResourceFormatConfig(
			colors: ResourceFormatConfig.AssetCatalog(
				common: makeCommon(colors.resolved),
				groupByCatalogName: colors.resolved.groupByCatalogName,
				groupByFolders: colors.resolved.groupByFolders,
				splitByKeyPath: colors.resolved.splitByKeyPath
			),
			images: ResourceFormatConfig.AssetCatalog(
				common: makeCommon(images.resolved),
				groupByCatalogName: images.resolved.groupByCatalogName,
				groupByFolders: images.resolved.groupByFolders,
				splitByKeyPath: images.resolved.splitByKeyPath
			),
			fonts: makeCommon(fonts.resolved),
			nibs: makeCommon(nibs.resolved),
			scnScenes: ResourceFormatConfig.AssetCatalog(
				common: makeCommon(scnScenes.resolved),
				groupByCatalogName: scnScenes.resolved.groupByCatalogName,
				groupByFolders: scnScenes.resolved.groupByFolders,
				splitByKeyPath: scnScenes.resolved.splitByKeyPath
			),
			storyboards: makeCommon(storyboards.resolved),
			xcStrings: ResourceFormatConfig.XCStrings(
				catalog: ResourceFormatConfig.Catalog(
					common: makeCommon(xcStrings.resolved),
					groupByCatalogName: xcStrings.resolved.groupByCatalogName
				),
				splitByKeyPath: xcStrings.resolved.splitByKeyPath
			),
			defaultFormat: ResourceFormatConfig.Resolved(
				common: rootCommon,
				groupByCatalogName: root.groupByCatalogName,
				splitByKeyPath: true
			)
		)
	}

	private func makeCommon(
		_ common: Manifest.FormatConfig.Common
	) -> ResourceFormatConfig.Common {
		makeCommon(
			indentor: common.indentor,
			indentSize: common.indentSize,
			accessLevel: common.accessLevel,
			numbers: common.numbers,
			acronyms: common.acronyms
		)
	}

	private func makeCommon(
		_ root: Manifest.FormatConfig.Root
	) -> ResourceFormatConfig.Common {
		makeCommon(
			indentor: root.indentor,
			indentSize: root.indentSize,
			accessLevel: root.accessLevel,
			numbers: root.numbers,
			acronyms: root.acronyms
		)
	}

	private func makeCommon(
		_ catalog: Manifest.FormatConfig.AssetCatalog
	) -> ResourceFormatConfig.Common {
		makeCommon(
			indentor: catalog.indentor,
			indentSize: catalog.indentSize,
			accessLevel: catalog.accessLevel,
			numbers: catalog.numbers,
			acronyms: catalog.acronyms
		)
	}

	private func makeCommon(
		_ catalog: Manifest.FormatConfig.Catalog
	) -> ResourceFormatConfig.Common {
		makeCommon(
			indentor: catalog.indentor,
			indentSize: catalog.indentSize,
			accessLevel: catalog.accessLevel,
			numbers: catalog.numbers,
			acronyms: catalog.acronyms
		)
	}

	private func makeCommon(
		_ xcStrings: Manifest.FormatConfig.XCStrings
	) -> ResourceFormatConfig.Common {
		makeCommon(
			indentor: xcStrings.indentor,
			indentSize: xcStrings.indentSize,
			accessLevel: xcStrings.accessLevel,
			numbers: xcStrings.numbers,
			acronyms: xcStrings.acronyms
		)
	}

	private func makeCommon(
		indentor: Manifest.Indentor,
		indentSize: Manifest.IndentSize,
		accessLevel: Manifest.AccessLevelConfig,
		numbers: Manifest.NumbersConfig,
		acronyms: Manifest.AcronymsConfig
	) -> ResourceFormatConfig.Common {
		let resolvedIndentSize = Manifest.Indentor.$current.withValue(indentor) {
			indentSize.rawValue
		}
		let resolvedIndentor = String(
			repeating: indentor.rawValue,
			count: resolvedIndentSize
		)

		return ResourceFormatConfig.Common(
			indentor: resolvedIndentor,
			accessLevel: accessLevel.rawValue,
			updateCasification: { config in
				config.camelCase.acronyms.processingPolicy = acronyms.processingPolicy.rawValue
				config.camelCase.numbers.separator = numbers.separator.rawValue
				config.camelCase.numbers.nextTokenMode = numbers.nextTokenMode.rawValue
				config.common.numbers.allowedDelimeters = numbers.allowedDelimeters.rawValue
				config.common.numbers.boundaryOptions = numbers.aliasedNumericBoundaryOptions
				config.acronyms = acronyms.resolvedValues
			}
		)
	}
}
