import PackageResourcesCore
import PackageResourcesFS

extension PackageResourcesClient.Operations.CollectResources {
	public static var standard: Self {
		.init { path in
			Result {
				try Folder(path: path).compactMapContents(recursive: true) { (content) -> [PRCLIResource]? in
					var output: [PRCLIResource] = []

					func collect(_ resources: PRCLIResourceConvertible?...) {
						output.append(contentsOf: resources.compactMap(\.?.spmGenResource))
					}

					switch content {
					case let .file(file):
						collect(
							font(from: file),
							nib(from: file),
							scene(from: file),
							storyboard(from: file)
						)

					case let .folder(folder):
						collect(
							color(from: folder),
							image(from: folder)
						)
					}

					return output
				}
				.flatMap { $0 }
			}
		}
	}
}

fileprivate func color(from folder: Folder) -> PRCLIColorResource? {
	guard ["colorset"].contains(folder.extension)
	else { return nil }

	return PRCLIColorResource(name: folder.nameExcludingExtension)
}

fileprivate func font(from file: File) -> PRCLIFontResource? {
	guard ["otf", "ttf"].contains(file.extension)
	else { return nil }

	return PRCLIFontResource(name: file.nameExcludingExtension)
}

fileprivate func image(from folder: Folder) -> PRCLIImageResource? {
	guard ["imageset"].contains(folder.extension)
	else { return nil }

	return PRCLIImageResource(name: folder.nameExcludingExtension)
}

fileprivate func nib(from file: File) -> PRCLINibResource? {
	guard ["xib"].contains(file.extension)
	else { return nil }

	return PRCLINibResource(name: file.nameExcludingExtension)
}

fileprivate func scene(from file: File) -> PRCLISCNSceneResource? {
	guard ["scn"].contains(file.extension)
	else { return nil }

	let parent = file.parent

	let catalog = ["scnassets"].contains(parent?.extension)
	? parent?.nameExcludingExtension
	: nil

	return PRCLISCNSceneResource(
		name: file.nameExcludingExtension,
		catalog: catalog
	)
}

fileprivate func storyboard(from file: File) -> PRCLIStoryboardResource? {
	guard ["storyboard"].contains(file.extension)
	else { return nil }

	return PRCLIStoryboardResource(name: file.nameExcludingExtension)
}
