import PackageResourcesCore
import XCStringsCatalog
import Dependencies
import IssueReporting

extension PackageResources.LocalizedString: _CollectableResourceType {
	public static func collect(atPath path: String) throws -> [Source] {
		try collectResources(atPath: path) { location in
			guard ["xcstrings", "stringsdict", "strings"].contains(location.extension)
			else { return [] }

			@Dependency(\.xcStringsCatalogParser)
			var parser

			let parsed: XCStringsCatalogParserOutput = withErrorReporting {
				try parser.parse(from: .init(contentsOf: location.url))
			} ?? .init(resources: [], issues: [])

			for issue in parsed.issues {
				reportIssue(issue.description)
			}

			let table = location.nameExcludingExtension
			return parsed.resources.map {
				.init(
					resource: $0,
					table: table
				)
			}
		}
	}
}
