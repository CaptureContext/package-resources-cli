extension Manifest {
	public struct FormatConfig {
		public var colors: Colors
		public var images: Images
		public var fonts: Fonts
		public var nibs: Common
		public var storyboards: Common
		public var xcStrings: XCStrings

		public init(
			colors: Colors = .init(),
			images: Images = .init(),
			fonts: Fonts = .init(),
			nibs: Common = .init(),
			storyboards: Common = .init(),
			xcStrings: XCStrings = .init()
		) {
			self.colors = colors
			self.images = images
			self.fonts = fonts
			self.nibs = nibs
			self.storyboards = storyboards
			self.xcStrings = xcStrings
		}
	}
}
