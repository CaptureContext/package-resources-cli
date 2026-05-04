import PackageResourcesCore

extension PackageResources.SCNScene: _CollectableResourceType {
	public static func collect(atPath path: String) throws -> [Source] {
		try collectResources(atPath: path) { location in
			guard ["scn"].contains(location.extension)
			else { return [] }

			let parent = location.parent

			let catalog = ["scnassets"].contains(parent?.extension)
			? parent?.nameExcludingExtension
			: nil

			return [
				.init(
					name: location.nameExcludingExtension,
					catalog: catalog
				)
			]
		}
	}
}
