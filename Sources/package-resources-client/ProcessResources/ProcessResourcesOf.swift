import PackageResourcesCore
import FunctionComposition
import KeyPathsExtensions
import Dependencies

extension DependencyValues {
	private enum ProcessResourcesKey<Resource: _CollectableResourceType>: DependencyKey {
		private static func defaultImplementation() -> SendableSyncThrowingFunc<String, String, Error> {
			@Dependency(KeyPath.collectResources(of: Resource.self))
			var collector

			@Dependency(KeyPath.renderResources(of: Resource.Source.self))
			var renderer

			return collector >>> renderer
		}

		static var liveValue: SendableSyncThrowingFunc<String, String, Error> {
			defaultImplementation()
		}

		static var testValue: SendableSyncThrowingFunc<String, String, Error> {
			defaultImplementation()
		}
	}

	public struct ResourceProcessorKey<Resource: Sendable>: Hashable {
		let id: ObjectIdentifier = .init(Resource.self)
		public static func type(_ type: Resource.Type) -> Self { .init() }
	}

	public subscript<
		Resource: _CollectableResourceType
	>(
		processResourcesOf resourceType: ResourceProcessorKey<Resource>
	) -> SendableSyncThrowingFunc<String, String, Error> {
		get { self[ProcessResourcesKey<Resource>.self] }
		set { self[ProcessResourcesKey<Resource>.self] = newValue }
	}
}

extension KeyPath where Root == DependencyValues {
	public static func processResources<Resource: _CollectableResourceType>(
		of resourceType: Resource.Type
	) -> _SendableKeyPath<Root, Value> where
	Value == SendableSyncThrowingFunc<String, String, Error>
	{
		(\DependencyValues.[processResourcesOf: .type(Resource.self)]).unsafeSendable()
	}
}

extension WritableKeyPath where Root == DependencyValues {
	public static func processResources<Resource: _CollectableResourceType>(
		of resourceType: Resource.Type
	) -> _SendableWritableKeyPath<Root, Value> where
	Value == SendableSyncThrowingFunc<String, String, Error>
	{
		(\DependencyValues.[processResourcesOf: .type(Resource.self)]).unsafeSendable()
	}
}
