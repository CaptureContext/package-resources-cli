import PackageResourcesCore

extension PackageResources.Nib {
	public struct Source: Hashable, Sendable {
		public var name: String

		public init(name: String) {
			self.name = name
		}
	}
}
