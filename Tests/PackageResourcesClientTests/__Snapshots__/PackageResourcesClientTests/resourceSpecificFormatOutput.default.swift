import Foundation
import PackageResourcesCore

extension _ColorResource {
  public enum media {
    public static var colorExample: Self {
      .init(
        name: "ColorExample",
        bundle: .module
      )
    }

    public static var nestedColor: Self {
      .init(
        name: "Nested.Color",
        bundle: .module
      )
    }
  }
}

extension _ImageResource {
    package enum media {
        package static var imageExample: Self {
            .init(
                name: "ImageExample",
                bundle: .module
            )
        }

        package static var nestedImage: Self {
            .init(
                name: "NestedImage",
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
  static var _customFonts: Self {
    return [
      .arimoBold,
      .montserratBlack,
    ]
  }
}

extension _FontResource {
  static var arimoBold: Self {
    .init(name: "Arimo-Bold")
  }

  static var montserratBlack: Self {
    .init(name: "Montserrat-Black")
  }
}

extension _XCStringResource {
    /// "Default localization %1$(string)@ %2$(int)lld and unnamed %3$lf"
    ///
    /// > Some comment
    public static func unformattedTestKeyWithValues(
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
