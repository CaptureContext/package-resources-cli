import PackageResourcesCore
import XCStringsCatalog

extension PackageResources.LocalizedString {
	public struct Source: Hashable, Sendable {
		public var resource: XCStringResource
		public var table: String?

		public init(
			resource: XCStringResource,
			table: String? = nil
		) {
			self.resource = resource
			self.table = table
		}
	}
}
