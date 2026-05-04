import Foundation
import PackageResourcesCore

extension PackageResources.Color {
	internal static var colorExample: Self {
		.init(
			name: "ColorExample",
			bundle: .module
		)
	}
}

extension PackageResources.Image {
	internal static var imageExample: Self {
		.init(
			name: "ImageExample",
			bundle: .module
		)
	}
}

extension PackageResources.Storyboard {
	internal static var main: Self {
		.init(
			name: "Main",
			bundle: .module
		)
	}
}

extension PackageResources.Nib {
	internal static var main: Self {
		.init(
			name: "Main",
			bundle: .module
		)
	}
}

extension Array where Element == PackageResources.Font {
	internal static var _customFonts: Self {
		return [
			.arimoBold,
			.montserratBlack
		]
	}
}

extension PackageResources.Font {
	internal static var arimoBold: Self {
		.init(name: "Arimo-Bold")
	}

	internal static var montserratBlack: Self {
		.init(name: "Montserrat-Black")
	}
}

extension PackageResources.LocalizedString {
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
							.double(arg3)
						],
						table: "Localizable",
						bundle: .module
					)
				}
			}
		}
	}
}
