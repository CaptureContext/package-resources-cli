import PackageResourcesFS

internal func collectResources<Resource>(
	atPath path: String,
	consume: (any _Location) -> [Resource]
) throws -> [Resource] {
	try Folder(path: path).compactMapContents(recursive: true) { content in
		consume(content.location)
	}.flatMap { $0 }
}

internal func xcAssetFolderComponents(
	for location: any _Location
) -> [String] {
	var components: [String] = []
	var parent = location.parent

	while let folder = parent {
		if folder.extension == "xcassets" {
			return components
		}

		components.insert(folder.name, at: 0)
		parent = folder.parent
	}

	return []
}
