import Casification

extension PackageResourcesClient.Operations.CamelCase {
	public static func standard(
		_ mode: String.Casification.Configuration.CamelCase.Mode = .automatic
	) -> Self {
		return .init {
			$0.case(.camel(mode))
		}
	}
}
