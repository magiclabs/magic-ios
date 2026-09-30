//
//  BitcoinConfiguration.swift
//  MagicSDK
//

import Foundation

internal enum BitcoinMethod: String {
    case btc_signTransaction
}

/// Enables the Bitcoin extension. Mirrors `BitcoinConfig` in `@magic-ext/bitcoin`.
public struct BitcoinConfiguration: ExtensionConfiguration {
    public let name = "bitcoin"
    public let rpcUrl: String
    public let network: String

    public init(rpcUrl: String, network: String) {
        self.rpcUrl = rpcUrl
        self.network = network
    }

    enum CodingKeys: String, CodingKey {
        case rpcUrl, chainType, options
    }

    enum OptionsKeys: String, CodingKey {
        case network
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rpcUrl, forKey: .rpcUrl)
        try container.encode(BitcoinExtension.chainType, forKey: .chainType)
        var options = container.nestedContainer(keyedBy: OptionsKeys.self, forKey: .options)
        try options.encode(network, forKey: .network)
    }
}

/// A UTXO to spend. `value` is in BTC (not satoshis), with at most eight decimal
/// places. The enclave needs this value to compute its segwit (BIP143) sighash.
/// `txNum` is the output index (vout) of the UTXO within its source transaction.
public struct BitcoinTransactionInput: Codable {
    public let txid: String
    public let txNum: Int
    public let value: Double
    public let address: String?

    public init(txid: String, txNum: Int, value: Double, address: String? = nil) {
        self.txid = txid
        self.txNum = txNum
        self.value = value
        self.address = address
    }

    enum CodingKeys: String, CodingKey {
        case txid
        case txNum = "tx_num"
        case value, address
    }
}

/// A transaction output. `value` is in BTC with at most eight decimal places.
public struct BitcoinTransactionOutput: Codable {
    public let address: String
    public let value: Double

    public init(address: String, value: Double) {
        self.address = address
        self.value = value
    }
}

/// The result of `signTransaction`.
public struct BitcoinSignedTransaction: MagicResponse {
    /// The broadcast-ready, fully-signed transaction as hex.
    public let signedTransaction: String
    /// The transaction hash (txid).
    public let transactionHash: String
}

/// Params for `btc_signTransaction`.
struct BitcoinTransactionParams: Codable {
    let inputs: [BitcoinTransactionInput]
    let outputs: [BitcoinTransactionOutput]
}
