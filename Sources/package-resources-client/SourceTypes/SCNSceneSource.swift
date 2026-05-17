import PackageResourcesCore

extension PackageResources.SCNScene {
	public struct Source: Hashable, Sendable {
		public var name: String
		public var path: [String]
		public var catalog: String?

		public init(
			name: String,
			path: [String] = [],
			catalog: String? = nil
		) {
			self.name = name
			self.path = path
			self.catalog = catalog
		}
	}
}
