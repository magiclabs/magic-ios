//
//  TypedArray.swift
//  MagicSDK
//

import Foundation

/// Binary data in the typed-array wire format that mgbox uses in both directions.
///
/// JSON has no binary type, so mgbox and `@magic-sdk/react-native-bare` send a
/// `Uint8Array` as
/// `{"constructor":"Uint8Array","data":"99,53,247","flag":"MAGIC_PAYLOAD_FLAG_TYPED_ARRAY"}`.
/// mgbox turns this back into a real `Uint8Array` before the relayer sees it. It
/// also encodes typed arrays in responses (e.g. Solana signatures) the same way.
public struct TypedArray: Codable, Equatable {

    static let flag = "MAGIC_PAYLOAD_FLAG_TYPED_ARRAY"

    public let data: Data

    public init(_ data: Data) {
        self.data = data
    }

    enum CodingKeys: String, CodingKey {
        case constructor, data, flag
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("Uint8Array", forKey: .constructor)
        try container.encode(data.map { $0.description }.joined(separator: ","), forKey: .data)
        try container.encode(TypedArray.flag, forKey: .flag)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard try container.decode(String.self, forKey: .flag) == TypedArray.flag else {
            throw DecodingError.dataCorruptedError(forKey: .flag, in: container, debugDescription: "Not a typed array")
        }
        // `Buffer` and `Uint8Array` both arrive here. Their bytes are joined the same way.
        let joined = try container.decode(String.self, forKey: .data)
        if joined.isEmpty {
            self.data = Data()
            return
        }
        var bytes: [UInt8] = []
        for part in joined.split(separator: ",", omittingEmptySubsequences: false) {
            guard let byte = UInt8(part) else {
                throw DecodingError.dataCorruptedError(forKey: .data, in: container, debugDescription: "Invalid byte: \(part)")
            }
            bytes.append(byte)
        }
        self.data = Data(bytes)
    }
}
