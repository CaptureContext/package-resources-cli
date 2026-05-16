import Foundation
import PackageResourcesCore

extension _ColorResource {
	internal enum media {
		internal enum nestedFolder {
			internal enum nested {
				internal static var color: Self {
					.init(
						name: "Nested.Color",
						bundle: .module
					)
				}
			}
		}

		internal static var colorExample: Self {
			.init(
				name: "ColorExample",
				bundle: .module
			)
		}
	}
}

extension _ImageResource {
	internal enum media {
		internal enum nestedFolder {
			internal static var nestedImage: Self {
				.init(
					name: "NestedImage",
					bundle: .module
				)
			}
		}

		internal static var imageExample: Self {
			.init(
				name: "ImageExample",
				bundle: .module
			)
		}
	}
}

extension _StoryboardResource {
	internal static var main: Self {
		.init(
			name: "Main",
			bundle: .module
		)
	}
}

extension _SCNSceneResource {
	internal static var defaultScene: Self {
		.init(
			name: "DefaultScene",
			catalog: "SCNCatalog",
			bundle: .module
		)
	}
}

extension _NibResource {
	internal static var main: Self {
		.init(
			name: "Main",
			bundle: .module
		)
	}
}

extension Array where Element == _FontResource {
	internal static var _customFonts: Self {
		return [
			.arimoBold,
			.montserratBlack,
		]
	}
}

extension _FontResource {
	internal static var arimoBold: Self {
		.init(name: "Arimo-Bold")
	}

	internal static var montserratBlack: Self {
		.init(name: "Montserrat-Black")
	}
}

extension _XCStringResource {
	internal enum localizable {
		internal enum unformatted {
			internal enum testKey {
				/// "Default localization %1$(string)@ %2$(int)lld and unnamed %3$lf"
				///
				/// > Some comment
				internal static func withValues(
					string arg1: String,
					int arg2: Int,
					_ arg3: Double
				) -> _XCStringResource {
					return .init(
						key: "unformatted.test_key.withValues",
						arguments: [
							.object(arg1),
							.int(arg2),
							.double(arg3),
						],
						table: "Localizable",
						bundle: .module
					)
				}
			}
		}
	}
}
