import SnapshotTesting

extension Snapshotting where Value == String, Format == String {
	/// A snapshot strategy for comparing strings based on equality.
	public static var swift: Self {
		Snapshotting(pathExtension: "swift", diffing: .lines)
	}
}
