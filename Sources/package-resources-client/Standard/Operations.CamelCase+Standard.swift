import Casification

extension PackageResourcesClient.Operations.CamelCase {
	public static func standard(
		_ policy: String.Casification.Modifiers.CamelCaseConfig.Mode = .automatic,
		acronyms: String.Casification.Modifiers.CamelCaseConfig.Acronyms = .init()
	) -> Self {
		return .init {
			$0.case(.camel(policy, acronyms: acronyms))
		}
	}
}
