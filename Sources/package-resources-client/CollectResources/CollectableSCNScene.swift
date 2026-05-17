import PackageResourcesCore

extension PackageResources.SCNScene: _CollectableResourceType {
	public static func collect(atPath path: String) throws -> [Source] {
		try collectResources(atPath: path) { location in
			guard ["scn"].contains(location.extension)
			else { return [] }

			return [
				.init(
					name: resourceSetName(for: location),
					path: scnAssetFolderComponents(for: location),
					catalog: scnAssetCatalogName(for: location)
				)
			]
		}
	}
}
