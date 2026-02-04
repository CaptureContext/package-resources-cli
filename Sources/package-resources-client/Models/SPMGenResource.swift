import PackageResourcesCore

public enum PRCLIResource: Equatable, PRCLIResourceConvertible {
	case color(PRCLIColorResource)
	case font(PRCLIFontResource)
	case image(PRCLIImageResource)
	case nib(PRCLINibResource)
	case scene(PRCLISCNSceneResource)
	case storyboard(PRCLIStoryboardResource)

	var spmGenResource: PRCLIResource { self }

	var resourceType: NamedType.Type {
		switch self {
		case .color: return PackageResources.Color.self
		case .font: return PackageResources.Font.self
		case .image: return PackageResources.Image.self
		case .nib: return PackageResources.Nib.self
		case .scene: return PackageResources.SCNScene.self
		case .storyboard: return PackageResources.Storyboard.self
		}
	}

	var name: String {
		switch self {
		case let .color(resource): return resource.name
		case let .font(resource): return resource.name
		case let .image(resource): return resource.name
		case let .nib(resource): return resource.name
		case let .scene(resource): return resource.name
		case let .storyboard(resource): return resource.name
		}
	}
}

protocol PRCLIResourceConvertible {
	var spmGenResource: PRCLIResource { get }
	var resourceType: NamedType.Type { get }
}

public struct PRCLIColorResource: Equatable, PRCLIResourceConvertible {
	var spmGenResource: PRCLIResource { .color(self) }
	var resourceType: NamedType.Type { PackageResources.Color.self }

	public init(name: String) {
		self.name = name
	}

	public var name: String
}

public struct PRCLIFontResource: Equatable, PRCLIResourceConvertible {
	var spmGenResource: PRCLIResource { .font(self) }
	var resourceType: NamedType.Type { PackageResources.Font.self }

	public init(name: String) {
		self.name = name
	}

	public var name: String
}

public struct PRCLIImageResource: Equatable, PRCLIResourceConvertible {
	var spmGenResource: PRCLIResource { .image(self) }
	var resourceType: NamedType.Type { PackageResources.Image.self }

	public init(name: String) {
		self.name = name
	}

	public var name: String
}

public struct PRCLINibResource: Equatable, PRCLIResourceConvertible {
	var spmGenResource: PRCLIResource { .nib(self) }
	var resourceType: NamedType.Type { PackageResources.Nib.self }

	public init(name: String) {
		self.name = name
	}

	public var name: String
}


public struct PRCLISCNSceneResource: Equatable, PRCLIResourceConvertible {
	var spmGenResource: PRCLIResource { .scene(self) }
	var resourceType: NamedType.Type { PackageResources.SCNScene.self }

	public init(name: String, catalog: String?) {
		self.name = name
		self.catalog = catalog
	}

	public var name: String
	public var catalog: String?
}

public struct PRCLIStoryboardResource: Equatable, PRCLIResourceConvertible {
	var spmGenResource: PRCLIResource { .storyboard(self) }
	var resourceType: NamedType.Type { PackageResources.Storyboard.self }

	public init(name: String) {
		self.name = name
	}

	public var name: String
}
