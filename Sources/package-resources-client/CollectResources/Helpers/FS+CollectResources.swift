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

internal func xcAssetCatalogName(
	for location: any _Location
) -> String? {
	var parent = location.parent

	while let folder = parent {
		if folder.extension == "xcassets" {
			return folder.name.removingSuffix(".xcassets")
		}

		parent = folder.parent
	}

	return nil
}

internal func resourceSetName(
	for location: any _Location
) -> String {
	if let locationExtension = location.extension {
		return location.name.removingSuffix(".\(locationExtension)")
	} else {
		return location.name
	}
}

private extension String {
	func removingSuffix(_ suffix: String) -> String {
		guard hasSuffix(suffix) else { return self }
		return String(dropLast(suffix.count))
	}
}
