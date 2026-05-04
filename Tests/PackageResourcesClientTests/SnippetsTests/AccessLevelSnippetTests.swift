import Testing
@testable import PackageResourcesClient

import CustomDump

@Suite
struct AccessLevelSnippetTests {
	@Test
	func rendersPrivateAccessLevel() {
		expectNoDifference("private", renderSnippet(AccessLevel.private))
	}

	@Test
	func rendersInternalAccessLevel() {
		expectNoDifference("internal", renderSnippet(AccessLevel.internal))
	}

	@Test
	func rendersPackageAccessLevel() {
		expectNoDifference("package", renderSnippet(AccessLevel.package))
	}

	@Test
	func rendersPublicAccessLevel() {
		expectNoDifference("public", renderSnippet(AccessLevel.public))
	}
}
