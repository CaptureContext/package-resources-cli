import SnapshotTesting

extension Snapshotting where Value == String, Format == String {
	static var yaml: Self {
		Snapshotting(pathExtension: "yml", diffing: .lines)
	}
}
