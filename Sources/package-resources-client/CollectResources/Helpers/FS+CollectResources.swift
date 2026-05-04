import PackageResourcesFS

internal func collectResources<Resource>(
	atPath path: String,
	consume: (any _Location) -> [Resource]
) throws -> [Resource] {
	try Folder(path: path).compactMapContents(recursive: true) { content in
		consume(content.location)
	}.flatMap { $0 }
}
