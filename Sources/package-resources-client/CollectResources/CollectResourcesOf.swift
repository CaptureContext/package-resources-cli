import FunctionComposition
import Dependencies
import KeyPathsExtensions
import PackageResourcesCore

public protocol _CollectableResourceType: Sendable {
	associatedtype Source: _RenderableResourceType & Hashable
	static func collect(atPath path: String) throws -> [Source]
}

extension DependencyValues {
	private enum CollectResourcesKey<Resource: _CollectableResourceType>: DependencyKey {
		private static func defaultImplementation() -> SendableSyncThrowingFunc<String, [Resource.Source], Error> {
			.init { try Resource.collect(atPath: $0) }
		}

		static var liveValue: SendableSyncThrowingFunc<String, [Resource.Source], Error> {
			defaultImplementation()
		}

		static var testValue: SendableSyncThrowingFunc<String, [Resource.Source], Error> {
			defaultImplementation()
		}
	}

	public struct ResourceCollectorKey<Resource: Sendable>: Hashable {
		let id: ObjectIdentifier = .init(Resource.self)
		public static func type(_ type: Resource.Type) -> Self { .init() }
	}

	public subscript<
		Resource: _CollectableResourceType
	>(
		collectResourcesOf resourceType: ResourceCollectorKey<Resource>
	) -> SendableSyncThrowingFunc<String, [Resource.Source], Error> {
		get { self[CollectResourcesKey<Resource>.self] }
		set { self[CollectResourcesKey<Resource>.self] = newValue }
	}
}

extension KeyPath where Root == DependencyValues {
	public static func collectResources<Resource: _CollectableResourceType>(
		of resourceType: Resource.Type
	) -> _SendableKeyPath<Root, Value> where
	Value == SendableSyncThrowingFunc<String, [Resource.Source], Error>
	{
		(\DependencyValues.[collectResourcesOf: .type(Resource.self)]).unsafeSendable()
	}
}

extension WritableKeyPath where Root == DependencyValues {
	public static func collectResources<Resource: _CollectableResourceType>(
		of resourceType: Resource.Type
	) -> _SendableWritableKeyPath<Root, Value> where
	Value == SendableSyncThrowingFunc<String, [Resource.Source], Error>
	{
		(\DependencyValues.[collectResourcesOf: .type(Resource.self)]).unsafeSendable()
	}
}
