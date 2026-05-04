import PackageResourcesCore

extension PackageResources.SCNScene {
	public struct Source: Hashable, Sendable {
		public var name: String
		public var catalog: String?

		public init(
			name: String,
			catalog: String?
		) {
			self.name = name
			self.catalog = catalog
		}
	}
}
