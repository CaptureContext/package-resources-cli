import FunctionComposition
import Dependencies
import KeyPathsExtensions

public protocol _RenderableResourceType: Sendable {
	static func render(_ resources: [Self]) throws -> String
}

extension DependencyValues {
	private enum RenderResourcesKey<Resource: _RenderableResourceType>: DependencyKey {
		private static func defaultImplementation() -> SendableSyncThrowingFunc<[Resource], String, Error> {
			.init { try Resource.render($0) }
		}

		static var liveValue: SendableSyncThrowingFunc<[Resource], String, Error> {
			defaultImplementation()
		}

		static var testValue: SendableSyncThrowingFunc<[Resource], String, Error> {
			defaultImplementation()
		}
	}

	public struct ResourceRendererKey<Resource: Sendable>: Hashable {
		let id: ObjectIdentifier = .init(Resource.self)
		public static func type(_ type: Resource.Type) -> Self { .init() }
	}

	public subscript<
		Resource: _RenderableResourceType
	>(
		renderResourcesOf resourceType: ResourceRendererKey<Resource>
	) -> SendableSyncThrowingFunc<[Resource], String, Error> {
		get { self[RenderResourcesKey<Resource>.self] }
		set { self[RenderResourcesKey<Resource>.self] = newValue }
	}
}

extension KeyPath where Root == DependencyValues {
	public static func renderResources<Resource: _RenderableResourceType>(
		of resourceType: Resource.Type
	) -> _SendableKeyPath<Root, Value> where
	Value == SendableSyncThrowingFunc<[Resource], String, Error>
	{
		(\DependencyValues.[renderResourcesOf: .type(Resource.self)]).unsafeSendable()
	}
}

extension WritableKeyPath where Root == DependencyValues {
	public static func renderResources<Resource: _RenderableResourceType>(
		of resourceType: Resource.Type
	) -> _SendableWritableKeyPath<Root, Value> where
	Value == SendableSyncThrowingFunc<[Resource], String, Error>
	{
		(\DependencyValues.[renderResourcesOf: .type(Resource.self)]).unsafeSendable()
	}
}

