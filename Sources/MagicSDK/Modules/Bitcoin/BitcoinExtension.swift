//
//  BitcoinExtension.swift
//  MagicSDK
//

import Foundation
import MagicSDK_Web3
import PromiseKit

/// Bitcoin extension for signing transactions.
/// Mirrors the `@magic-ext/bitcoin` package in magic-js.
public class BitcoinExtension: MultichainExtension {

    static let chainType = "BITCOIN"

    init(rpcProvider: RpcProvider) {
        super.init(rpcProvider: rpcProvider, chain: BitcoinExtension.chainType)
    }

    // MARK: - Sign Transaction

    /// Signs a Bitcoin transaction in the TEE. The caller supplies fully-formed
    /// inputs (the UTXOs to spend, each with its value) and outputs. Coin
    /// selection, fee, and change are the caller's job. Resolves with the
    /// broadcast-ready signed transaction.
    ///
    /// Input and output values are non-negative BTC amounts with at most eight
    /// decimal places. Tiny floating-point errors (up to 0.001 sat) are
    /// tolerated. Work out fees and change in integer satoshis, then convert to
    /// BTC for this method. Total outputs must not exceed total inputs. The
    /// difference is the fee. There is no minimum or maximum signing fee, and
    /// no dust threshold is enforced. Check the fee rate (sats/vB) and output
    /// amounts against the broadcasting node's policy. Signing does not
    /// guarantee relay, confirmation, or UTXO availability. Invalid
    /// transaction params fail with an RPC error that describes the problem.
    public func signTransaction(inputs: [BitcoinTransactionInput], outputs: [BitcoinTransactionOutput], response: @escaping Web3ResponseCompletion<BitcoinSignedTransaction>) {
        let request = RPCRequest<[BitcoinTransactionParams]>(
            method: BitcoinMethod.btc_signTransaction.rawValue,
            params: [BitcoinTransactionParams(inputs: inputs, outputs: outputs)]
        )
        self.provider.send(request: request, response: response)
    }

    /// Promise-based overload of `signTransaction`.
    public func signTransaction(inputs: [BitcoinTransactionInput], outputs: [BitcoinTransactionOutput]) -> Promise<BitcoinSignedTransaction> {
        return Promise { resolver in
            signTransaction(inputs: inputs, outputs: outputs, response: promiseResolver(resolver))
        }
    }
}

// MARK: - Magic extension

public extension Magic {
    /// Access Bitcoin methods. `nil` unless `Magic` was created with a `BitcoinConfiguration`.
    var bitcoin: BitcoinExtension? {
        guard extensionConfigurations.contains(where: { $0 is BitcoinConfiguration }) else { return nil }
        return BitcoinExtension(rpcProvider: self.rpcProvider)
    }
}
