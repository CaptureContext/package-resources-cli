import Yams
import Foundation

extension Manifest {
	enum Format {
		case yaml
		case json
	}

	static func load(at path: String) throws -> Self {
		try loadWithFormat(at: path).config
	}

	static func loadWithFormat(at path: String) throws -> (config: Self, format: Format) {
		guard FileManager.default.fileExists(atPath: path)
		else { throw _Error("File missing at \(path)") }

		let url = URL(fileURLWithPath: path)

		guard let data = try? Data(contentsOf: url)
		else { throw _Error("Couldn't read file at \(path)") }

		typealias Decode = () throws -> (Self, Format)
		let decodeJSON: Decode = { try (JSONDecoder().decode(Self.self, from: data), .json) }
		let decodeYAML: Decode = { try (YAMLDecoder().decode(Self.self, from: data), .yaml) }

		if url.pathExtension == "json" {
			do {
				return try decodeJSON()
			} catch {
				do {
					return try decodeYAML()
				} catch {
					throw error
				}
			}
		} else {
			do {
				return try decodeYAML()
			} catch {
				throw error
			}
		}
	}

	static func debugLoad(at path: String) throws -> Self {
		guard FileManager.default.fileExists(atPath: path)
		else { throw _Error("File missing at \(path)") }

		let url = URL(fileURLWithPath: path)

		guard let data = try? Data(contentsOf: url)
		else { throw _Error("Couldn't read file at \(path)") }

		typealias Decode = () throws -> Self
		let decodeJSON: Decode = { try JSONDecoder().decode(Self.self, from: data) }
		let decodeYAML: Decode = { try YAMLDecoder().decode(Self.self, from: data) }

		if url.pathExtension == "json" {
			do {
				return try decodeJSON()
			} catch {
				do {
					return try decodeYAML()
				} catch {
					throw error
				}
			}
		} else {
			do {
				return try decodeYAML()
			} catch {
				throw error
			}
		}
	}
}
