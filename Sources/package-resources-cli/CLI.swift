/// Using main.swift with async commands crashes the binary
/// https://github.com/apple/swift-argument-parser/issues/688
///
/// Remove the wrapper when the issue is fixed:
/// - rename file to `main.swift`
/// - call `await App.main()` directly
@main
struct CLI {
	static func main() async {
		await App.main()
	}
}
