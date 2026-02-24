import Yams
import Foundation

extension Manifest {
	enum Format {
		 case yaml
		 case json
	 }

	static func load(at path: String) -> Self? {
		loadWithFormat(at: path)?.config
	}

	static func loadWithFormat(at path: String) -> (config: Self, format: Format)? {
		guard FileManager.default.fileExists(atPath: path)
		else { return nil }

		let url = URL(fileURLWithPath: path)

		guard let data = try? Data(contentsOf: url)
		else { return nil }

		typealias Decode = () throws -> (Self, Format)
		let decodeJSON: Decode = { try (JSONDecoder().decode(Self.self, from: data), .json) }
		let decodeYAML: Decode = { try (YAMLDecoder().decode(Self.self, from: data), .yaml) }

		if url.pathExtension == "json" {
			return (try? decodeJSON()) ?? (try? decodeYAML())
		} else {
			return (try? decodeYAML()) ?? (try? decodeJSON())
		}
	}
}
