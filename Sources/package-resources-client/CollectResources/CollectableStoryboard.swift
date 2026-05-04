import PackageResourcesCore

extension PackageResources.Storyboard: _CollectableResourceType {
	public static func collect(atPath path: String) throws -> [Source] {
		try collectResources(atPath: path) { location in
			guard ["storyboard"].contains(location.extension)
			else { return [] }

			return [
				.init(name: location.nameExcludingExtension)
			]
		}
	}
}
