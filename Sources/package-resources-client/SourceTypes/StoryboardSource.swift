import PackageResourcesCore

extension PackageResources.Storyboard {
	public struct Source: Hashable, Sendable {
		public var name: String

		public init(name: String) {
			self.name = name
		}
	}
}
