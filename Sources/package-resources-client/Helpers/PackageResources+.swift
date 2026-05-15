import PackageResourcesCore

extension PackageResources.Color: NamedType {
	static var typeName: String { "_ColorResource" }
}

extension PackageResources.Font: NamedType {
	static var typeName: String { "_FontResource" }
}

extension PackageResources.Image: NamedType {
	static var typeName: String { "_ImageResource" }
}

extension PackageResources.Nib: NamedType {
	static var typeName: String { "_NibResource" }
}

extension PackageResources.SCNScene: NamedType {
	static var typeName: String { "_SCNSceneResource" }
}

extension PackageResources.Storyboard: NamedType {
	static var typeName: String { "_StoryboardResource" }
}

extension PackageResources.LocalizedString: NamedType {
	static var typeName: String { "_XCStringResource" }
}
