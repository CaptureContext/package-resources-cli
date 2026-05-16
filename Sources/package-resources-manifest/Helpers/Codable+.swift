// Source: https://github.com/capturecontext/swift-foundation-extensions

import Foundation

public enum RawCodingKey: CodingKey, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral, Hashable {
	case key(String)
	case index(Int)

	public init(stringLiteral value: String) {
		self.init(stringValue: value)
	}

	public init(stringValue: String) {
		self = .key(stringValue)
	}

	public init(integerLiteral value: Int) {
		self.init(intValue: value)
	}

	public init(intValue: Int) {
		self = .index(intValue)
	}

	public var stringValue: String {
		switch self {
		case let .key(value):
			return value
		case let .index(value):
			return value.description
		}
	}

	public var intValue: Int? {
		switch self {
		case let .index(value):
			return value
		default:
			return nil
		}
	}
}

extension Decoder {
	func decode<T>(
		_ decode: (KeyedDecodingContainer<RawCodingKey>) throws -> T
	) throws -> T {
		return try self.decode(RawCodingKey.self, decode)
	}

	func decode<CodingKeys: CodingKey, T>(
		_ codingKeys: CodingKeys.Type,
		_ decode: (KeyedDecodingContainer<CodingKeys>) throws -> T
	) throws -> T {
		let container = try container(keyedBy: codingKeys)
		return try decode(container)
	}
}

extension Encoder {
	func encode<T>(
		_ encode: (inout KeyedEncodingContainer<RawCodingKey>) throws -> T
	) throws -> T {
		return try self.encode(RawCodingKey.self, encode)
	}

	func encode<CodingKeys: CodingKey, T>(
		_ codingKeys: CodingKeys.Type,
		_ encode: (inout KeyedEncodingContainer<CodingKeys>) throws -> T
	) throws -> T {
		var container = container(keyedBy: codingKeys)
		return try encode(&container)
	}
}

extension KeyedEncodingContainer {
	mutating func nestedContainer(forKey key: Key) -> KeyedEncodingContainer<RawCodingKey> {
		self.nestedContainer(keyedBy: RawCodingKey.self, forKey: key)
	}

	mutating func nested<T>(
		_ key: Key,
		encode: (inout KeyedEncodingContainer<RawCodingKey>) throws -> T
	) throws -> T {
		var container = nestedContainer(forKey: key)
		return try encode(&container)
	}
}

extension KeyedDecodingContainer {
	func hasEquivalent(for key: CodingKey) -> Bool {
		allKeys.contains(where: {
			$0.stringValue == key.stringValue
		})
	}

	func decode<T: Decodable>(
		_ key: K
	) throws -> T {
		try decode(T.self, forKey: key)
	}

	func decodeIfPresent<T: Decodable>(
		_ key: K
	) throws -> T? {
		try decodeIfPresent(T.self, forKey: key)
	}

	func nestedContainer(forKey key: Key) throws -> KeyedDecodingContainer<RawCodingKey> {
		try self.nestedContainer(keyedBy: RawCodingKey.self, forKey: key)
	}

	func nested<T>(
		_ key: Key,
		decode: (KeyedDecodingContainer<RawCodingKey>) throws -> T
	) throws -> T {
		return try decode(nestedContainer(forKey: key))
	}

	func nestedIfPresent<T>(
		_ key: Key,
		decode: (KeyedDecodingContainer<RawCodingKey>) throws -> T
	) throws -> T? {
		guard hasEquivalent(for: key) else { return nil }
		return try decode(nestedContainer(forKey: key))
	}
}
