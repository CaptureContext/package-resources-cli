import Testing
@testable import PackageResourcesClient

@Suite
struct CollectResourcesTests {
	@Test
	func main() async throws {
		let actual = try PackageResourcesClient.Operations.CollectResources.standard(
			atPath: testResourcesDirectoryPath
		).get()

		let expected: [PRCLIResource] = [
			.font(.init(name: "Arimo-Bold")),
			.font(.init(name: "Montserrat-Black")),
			.storyboard(.init(name: "Main")),
			.nib(.init(name: "Main")),
			.color(.init(name: "ColorExample")),
			.image(.init(name: "ImageExample")),
			.scene(.init(name: "DefaultScene", catalog: "SCNCatalog")),
		]

		#expect(actual == expected)
	}
}
