import PackageResourcesCore

extension PackageResources.Nib: _CollectableResourceType {
	public static func collect(atPath path: String) throws -> [Source] {
		try collectResources(atPath: path) { location in
			guard ["nib", "xib"].contains(location.extension)
			else { return [] }
			
			return [
				.init(name: location.nameExcludingExtension)
			]
		}
	}
}
