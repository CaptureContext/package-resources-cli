import PackageResourcesCore

extension PackageResources.Color: _CollectableResourceType {
	public static func collect(atPath path: String) throws -> [Source] {
		try collectResources(atPath: path) { location in
			guard ["colorset"].contains(location.extension)
			else { return [] }

			return [
				.init(name: location.nameExcludingExtension)
			]
		}
	}
}
