import PackageResourcesCore

extension PackageResources.Image {
	public struct Source: Hashable, Sendable {
		public var name: String
		public var path: [String]

		public init(name: String, path: [String] = []) {
			self.name = name
			self.path = path
		}
	}
}
