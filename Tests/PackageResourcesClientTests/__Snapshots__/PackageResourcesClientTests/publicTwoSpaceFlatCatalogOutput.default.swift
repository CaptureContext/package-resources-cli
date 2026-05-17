import Foundation
import PackageResourcesCore

extension _ColorResource {
  public enum nestedFolder {
    public enum nested {
      public static var color: _ColorResource {
        .init(
          name: "Nested.Color",
          bundle: .module
        )
      }
    }
  }

  public static var colorExample: Self {
    .init(
      name: "ColorExample",
      bundle: .module
    )
  }
}

extension _ImageResource {
  public enum nestedFolder {
    public static var nestedImage: _ImageResource {
      .init(
        name: "NestedImage",
        bundle: .module
      )
    }
  }

  public static var imageExample: Self {
    .init(
      name: "ImageExample",
      bundle: .module
    )
  }
}

extension _StoryboardResource {
  public static var main: Self {
    .init(
      name: "Main",
      bundle: .module
    )
  }
}

extension _SCNSceneResource {
  public static var defaultScene: Self {
    .init(
      name: "DefaultScene",
      catalog: "SCNCatalog",
      bundle: .module
    )
  }
}

extension _NibResource {
  public static var main: Self {
    .init(
      name: "Main",
      bundle: .module
    )
  }
}

extension Array where Element == _FontResource {
  public static var _customFonts: Self {
    return [
      .arimoBold,
      .montserratBlack,
    ]
  }
}

extension _FontResource {
  public static var arimoBold: Self {
    .init(name: "Arimo-Bold")
  }

  public static var montserratBlack: Self {
    .init(name: "Montserrat-Black")
  }
}

extension _XCStringResource {
  public enum unformatted {
    public enum testKey {
      /// "Default localization %1$(string)@ %2$(int)lld and unnamed %3$lf"
      ///
      /// > Some comment
      public static func withValues(
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
