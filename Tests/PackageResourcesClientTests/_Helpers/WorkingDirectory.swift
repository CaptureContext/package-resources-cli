let workingDirectoryPath: String = #filePath
	.components(separatedBy: "/")
	.dropLast() // File name
	.dropLast() // Helpers directory
	.joined(separator: "/")

let testFixturesDirectoryPath: String = workingDirectoryPath.appending("/__Fixtures__")
let testSnapshotsDirectoryPath: String = workingDirectoryPath.appending("/__Snapshots__")
