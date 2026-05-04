import PackageResourcesCore

extension PackageResources.Font: _CollectableResourceType {
	public static func collect(atPath path: String) throws -> [Source] {
		try collectResources(atPath: path) { location in
			guard ["otf", "ttf"].contains(location.extension)
			else { return [] }

			return [
				.init(name: location.nameExcludingExtension)
			]
		}
	}
}
