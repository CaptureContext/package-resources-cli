import Testing
@testable import PackageResourcesClient

@Suite
struct ProcessResourcesStringTests {
	@Test
	func main() async throws {
		let actual = try PackageResourcesClient.Operations.ProcessResources.standard()(
			atPath: testResourcesDirectoryPath
		).get()!

		let expected = """
		extension PackageResources.Color {
			public static var colorExample: Self {
				return .init(name: "ColorExample", bundle: .module)
			}
		}

		extension Array where Element == PackageResources.Font {
			@available(*, deprecated, renamed: "_customFonts")
			public static var _spmgen: Self { _customFonts }
		
			public static var _customFonts: Self {[
				.arimoBold,
				.montserratBlack,
			]}
		}

		extension PackageResources.Font {
			public static var arimoBold: Self {
				return .init(name: "Arimo-Bold")
			}

			public static var montserratBlack: Self {
				return .init(name: "Montserrat-Black")
			}
		}

		extension PackageResources.Image {
			public static var imageExample: Self {
				return .init(name: "ImageExample", bundle: .module)
			}
		}

		extension PackageResources.Nib {
			public static var main: Self {
				return .init(name: "Main", bundle: .module)
			}
		}

		extension PackageResources.SCNScene {
			public static var defaultScene: Self {
				return .init(name: "DefaultScene", catalog: "SCNCatalog", bundle: .module)
			}
		}

		extension PackageResources.Storyboard {
			public static var main: Self {
				return .init(name: "Main", bundle: .module)
			}
		}
		"""

		#expect(actual == expected)
	}
}
