//
//  SolanaConfiguration.swift
//  MagicSDK
//

import Foundation

internal enum SolanaMethod: String {
    case sol_signTransaction
    case sol_signMessage
    case sol_partialSignTransaction
}

/// Enables the Solana extension. Mirrors `SolanaConfig` in `@magic-ext/solana`.
public struct SolanaConfiguration: ExtensionConfiguration {
    public let name = "solana"
    public let rpcUrl: String

    public init(rpcUrl: String) {
        self.rpcUrl = rpcUrl
    }

    enum CodingKeys: String, CodingKey {
        case rpcUrl, chainType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rpcUrl, forKey: .rpcUrl)
        try container.encode(SolanaExtension.chainType, forKey: .chainType)
    }
}

/// The format of a serialized Solana transaction.
public enum SolanaTransactionType {
    /// A legacy `Transaction`.
    case legacy
    /// A version 0 `VersionedTransaction`.
    case v0
}

/// Options for serializing a legacy transaction.
/// Mirrors `SerializeConfig` in `@solana/web3.js`.
public struct SolanaSerializeConfig: Codable {
    public let requireAllSignatures: Bool?
    public let verifySignatures: Bool?

    public init(requireAllSignatures: Bool? = nil, verifySignatures: Bool? = nil) {
        self.requireAllSignatures = requireAllSignatures
        self.verifySignatures = verifySignatures
    }
}

/// The signed transaction returned by `signTransaction` and `partialSignTransaction`.
public struct SolanaSignedTransaction: MagicResponse {
    /// The serialized signed transaction.
    public let rawTransaction: Data

    enum CodingKeys: String, CodingKey {
        case rawTransaction
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rawTransaction = try container.decode(TypedArray.self, forKey: .rawTransaction).data
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(TypedArray(rawTransaction), forKey: .rawTransaction)
    }
}

/// Params for `sol_signTransaction` and `sol_partialSignTransaction`.
/// magic-js sends `type` as the string `legacy` or the number `0`.
struct SolanaTransactionParams: Codable {
    let type: SolanaTransactionType
    let serialized: TypedArray
    let serializeConfig: SolanaSerializeConfig?

    enum CodingKeys: String, CodingKey {
        case type, serialized, serializeConfig
    }

    init(type: SolanaTransactionType, serialized: Data, serializeConfig: SolanaSerializeConfig?) {
        self.type = type
        self.serialized = TypedArray(serialized)
        self.serializeConfig = serializeConfig
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch type {
        case .legacy:
            try container.encode("legacy", forKey: .type)
        case .v0:
            try container.encode(0, forKey: .type)
        }
        try container.encode(serialized, forKey: .serialized)
        try container.encodeIfPresent(serializeConfig, forKey: .serializeConfig)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = (try? container.decode(String.self, forKey: .type)) == "legacy" ? .legacy : .v0
        self.serialized = try container.decode(TypedArray.self, forKey: .serialized)
        self.serializeConfig = try container.decodeIfPresent(SolanaSerializeConfig.self, forKey: .serializeConfig)
    }
}

/// Params for `sol_signMessage`. The message is sent as a string or as bytes.
struct SolanaSignMessageParams: Codable {
    enum Message {
        case string(String)
        case bytes(TypedArray)
    }

    let message: Message

    enum CodingKeys: String, CodingKey {
        case message
    }

    init(message: Message) {
        self.message = message
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch message {
        case .string(let value):
            try container.encode(value, forKey: .message)
        case .bytes(let value):
            try container.encode(value, forKey: .message)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(String.self, forKey: .message) {
            self.message = .string(value)
        } else {
            self.message = .bytes(try container.decode(TypedArray.self, forKey: .message))
        }
    }
}
