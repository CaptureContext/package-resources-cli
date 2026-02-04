extension PackageResourcesClient {
	public static var standard: PackageResourcesClient {
		PackageResourcesClient(processResources: .standard())
	}
}
