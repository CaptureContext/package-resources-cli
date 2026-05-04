import PackageResourcesCore

extension PackageResources.Image: _CollectableResourceType {
	public static func collect(atPath path: String) throws -> [Source] {
		try collectResources(atPath: path) { location in
			guard ["imageset"].contains(location.extension)
			else { return [] }
			
			return [
				.init(name: location.nameExcludingExtension)
			]
		}
	}
}
