import Testing
@testable import PackageResourcesClient

import CustomDump
import Dependencies
import PackageResourcesCore
import XCStringsCatalog

@Suite
struct XCStringRendererTests {
	@Test
	func rendersNestedCatalogAndKeyPathEnums() throws {
		let output = try PackageResources.LocalizedString.Source.render([
			.init(
				resource: .init(
					key: "auth.login.title",
					comment: "Login title",
					arguments: [],
					sourceLocalization: "Log in"
				),
				table: "Localizable"
			),
			.init(
				resource: .init(
					key: "auth.logout.title",
					comment: "Logout title",
					arguments: [],
					sourceLocalization: "Log out"
				),
				table: "Localizable"
			)
		])

		let expected = """
		extension _XCStringResource {
			internal enum localizable {
				internal enum auth {
					internal enum login {
						/// "Log in"
						///
						/// > Login title
						internal static var title: _XCStringResource {
							return .init(
								key: "auth.login.title",
								arguments: [],
								table: "Localizable",
								bundle: .module
							)
						}
					}
		
					internal enum logout {
						/// "Log out"
						///
						/// > Logout title
						internal static var title: _XCStringResource {
							return .init(
								key: "auth.logout.title",
								arguments: [],
								table: "Localizable",
								bundle: .module
							)
						}
					}
				}
			}
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rendersRootAccessorAndAllArgumentTypes() throws {
		let output = try PackageResources.LocalizedString.Source.render([
			.init(
				resource: .init(
					key: "welcome",
					comment: nil,
					arguments: [],
					sourceLocalization: "Welcome"
				)
			),
			.init(
				resource: .init(
					key: "stats.summary",
					comment: "Stats summary",
					arguments: [
						.init(label: "count", name: "count", placeholderType: .int),
						.init(label: "total", name: "total", placeholderType: .uint),
						.init(label: "ratio", name: "ratio", placeholderType: .float),
						.init(label: "average", name: "average", placeholderType: .double),
						.init(label: nil, name: "name", placeholderType: .object)
					],
					sourceLocalization: "%1$lld %2$llu %3$f %4$lf %5$@"
				)
			)
		])

		let expected = """
		extension _XCStringResource {
			internal enum stats {
				/// "%1$lld %2$llu %3$f %4$lf %5$@"
				///
				/// > Stats summary
				internal static func summary(
					count: Int,
					total: UInt,
					ratio: Float,
					average: Double,
					_ name: String
				) -> _XCStringResource {
					return .init(
						key: "stats.summary",
						arguments: [
							.int(count),
							.uint(total),
							.float(ratio),
							.double(average),
							.object(name),
						],
						table: nil,
						bundle: .module
					)
				}
			}
		
			/// "Welcome"
			///
			/// > <no_comment>
			internal static var welcome: _XCStringResource {
				return .init(
					key: "welcome",
					arguments: [],
					table: nil,
					bundle: .module
				)
			}
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func respectsFormattingOverrides() throws {
		let output = try withDependencies {
			$0.resourceFormatConfig = .standard(indentor: " ", indentSize: 2, accessLevel: .public)
		} operation: {
			try PackageResources.LocalizedString.Source.render([
				.init(
					resource: .init(
						key: "auth.login.title",
						comment: "Login title",
						arguments: [],
						sourceLocalization: "Log in"
					),
					table: "Localizable"
				)
			])
		}

		let expected = """
		extension _XCStringResource {
		  public enum localizable {
		    public enum auth {
		      public enum login {
		        /// "Log in"
		        ///
		        /// > Login title
		        public static var title: _XCStringResource {
		          return .init(
		            key: "auth.login.title",
		            arguments: [],
		            table: "Localizable",
		            bundle: .module
		          )
		        }
		      }
		    }
		  }
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func skipsCatalogEnumWhenCatalogGroupingIsDisabled() throws {
		let output = try withDependencies {
			$0.resourceFormatConfig = .standard(groupByCatalogName: false)
		} operation: {
			try PackageResources.LocalizedString.Source.render([
				.init(
					resource: .init(
						key: "auth.login.title",
						comment: "Login title",
						arguments: [],
						sourceLocalization: "Log in"
					),
					table: "Localizable"
				)
			])
		}

		let expected = """
		extension _XCStringResource {
			internal enum auth {
				internal enum login {
					/// "Log in"
					///
					/// > Login title
					internal static var title: _XCStringResource {
						return .init(
							key: "auth.login.title",
							arguments: [],
							table: "Localizable",
							bundle: .module
						)
					}
				}
			}
		}
		"""

		expectNoDifference(expected, output)
	}

	@Test
	func rejectsConflictingAccessorAndNestedKeyPaths() throws {
		let resources = [
			PackageResources.LocalizedString.Source(
				resource: .init(
					key: "some.key",
					comment: nil,
					arguments: [],
					sourceLocalization: "Some key"
				)
			),
			.init(
				resource: .init(
					key: "some.key.label",
					comment: nil,
					arguments: [],
					sourceLocalization: "Some key label"
				)
			)
		]

		for resources in [resources, resources.reversed()] {
			do {
				_ = try PackageResources.LocalizedString.Source.render(Array(resources))
				Issue.record("Expected conflicting key paths to throw.")
			} catch let error as XCStringResourceValidationError {
				expectNoDifference(
					.conflictingKeyPaths([
						.init(accessorKey: "some.key", nestedKey: "some.key.label")
					]),
					error
				)
			} catch {
				Issue.record("Expected XCStringResourceValidationError, got \(error).")
			}
		}
	}

	@Test
	func rendersFlatAccessorsAndSkipsConflictValidationWhenKeyPathSplittingIsDisabled() throws {
		let output = try withDependencies {
			var config = ResourceFormatConfig.standard(groupByCatalogName: false)
			config.xcStrings.splitByKeyPath = false
			$0.resourceFormatConfig = config
		} operation: {
			try PackageResources.LocalizedString.Source.render([
				.init(
					resource: .init(
						key: "some.key",
						comment: nil,
						arguments: [],
						sourceLocalization: "Some key"
					)
				),
				.init(
					resource: .init(
						key: "some.key.label",
						comment: nil,
						arguments: [],
						sourceLocalization: "Some key label"
					)
				)
			])
		}

		let expected = """
		extension _XCStringResource {
			/// "Some key"
			///
			/// > <no_comment>
			internal static var someKey: _XCStringResource {
				return .init(
					key: "some.key",
					arguments: [],
					table: nil,
					bundle: .module
				)
			}

			/// "Some key label"
			///
			/// > <no_comment>
			internal static var someKeyLabel: _XCStringResource {
				return .init(
					key: "some.key.label",
					arguments: [],
					table: nil,
					bundle: .module
				)
			}
		}
		"""

		expectNoDifference(expected, output)
	}
}
