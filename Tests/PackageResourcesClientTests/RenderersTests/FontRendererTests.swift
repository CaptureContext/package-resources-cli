import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore

@Suite
struct FontRendererTests {
	@Test
	func rendersCustomFontListAndAccessors() throws {
		let output = try PackageResources.Font.Source.render([
			.init(name: "Montserrat-Black"),
			.init(name: "Arimo-Bold")
		])

		let expected = """
		extension Array where Element == _FontResource {
			internal static var _customFonts: Self {
				return [
					.arimoBold,
					.montserratBlack,
				]
			}
		}
		
		extension _FontResource {
			internal static var montserratBlack: Self {
				.init(name: "Montserrat-Black")
			}
		
			internal static var arimoBold: Self {
				.init(name: "Arimo-Bold")
			}
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsFormattingOverrides() throws {
		let output = try withDependencies {
			$0.formatClient = .standard(
				indentor: " ",
				indentSize: 2,
				accessLevel: .public
			)
		} operation: {
			try PackageResources.Font.Source.render([
				.init(name: "Arimo-Bold")
			])
		}

		let expected = """
		extension Array where Element == _FontResource {
		  public static var _customFonts: Self {
		    return [
		      .arimoBold,
		    ]
		  }
		}

		extension _FontResource {
		  public static var arimoBold: Self {
		    .init(name: "Arimo-Bold")
		  }
		}
		"""

		expectNoDifference(expected, output)
	}
}
