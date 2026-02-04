public struct RenderedAccessor: Equatable {
	public let initialResource: PRCLIResource
	public let stringValue: String

	public init(
		initialResource: PRCLIResource,
		stringValue: String
	) {
		self.initialResource = initialResource
		self.stringValue = stringValue
	}
}
