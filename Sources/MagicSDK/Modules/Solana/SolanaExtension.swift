//
//  SolanaExtension.swift
//  MagicSDK
//

import Foundation
import MagicSDK_Web3
import PromiseKit

/// Solana extension for signing transactions and messages.
/// Mirrors the `@magic-ext/solana` package in magic-js.
///
/// magic-js takes `Transaction` and `VersionedTransaction` objects from
/// `@solana/web3.js`. This SDK has no Solana dependency, so it takes the
/// serialized transaction bytes and their `SolanaTransactionType` instead.
/// Serialize a legacy transaction the same way you would pass it to magic-js,
/// usually with `requireAllSignatures: false`.
public class SolanaExtension: MultichainExtension {

    static let chainType = "SOLANA"

    init(rpcProvider: RpcProvider) {
        super.init(rpcProvider: rpcProvider, chain: SolanaExtension.chainType)
    }

    // MARK: - Sign Transaction

    /// Signs a Solana transaction.
    ///
    /// - Parameters:
    ///   - serialized: The serialized transaction.
    ///   - type: `.legacy` for a `Transaction`, `.v0` for a `VersionedTransaction`.
    ///   - serializeConfig: The config used to serialize the signed legacy transaction.
    ///   - response: Completion handler called with the signed transaction or an error.
    public func signTransaction(_ serialized: Data, type: SolanaTransactionType, serializeConfig: SolanaSerializeConfig? = nil, response: @escaping Web3ResponseCompletion<SolanaSignedTransaction>) {
        let request = RPCRequest<SolanaTransactionParams>(
            method: SolanaMethod.sol_signTransaction.rawValue,
            params: SolanaTransactionParams(type: type, serialized: serialized, serializeConfig: serializeConfig)
        )
        self.provider.send(request: request, response: response)
    }

    /// Promise-based overload of `signTransaction`.
    public func signTransaction(_ serialized: Data, type: SolanaTransactionType, serializeConfig: SolanaSerializeConfig? = nil) -> Promise<SolanaSignedTransaction> {
        return Promise { resolver in
            signTransaction(serialized, type: type, serializeConfig: serializeConfig, response: promiseResolver(resolver))
        }
    }

    // MARK: - Partial Sign Transaction

    /// Adds the user's signature to a transaction that other parties also sign.
    ///
    /// - Parameters:
    ///   - serialized: The serialized transaction.
    ///   - type: `.legacy` for a `Transaction`, `.v0` for a `VersionedTransaction`.
    ///   - serializeConfig: The config used to serialize the signed legacy transaction.
    ///   - response: Completion handler called with the partly signed transaction or an error.
    public func partialSignTransaction(_ serialized: Data, type: SolanaTransactionType, serializeConfig: SolanaSerializeConfig? = nil, response: @escaping Web3ResponseCompletion<SolanaSignedTransaction>) {
        let request = RPCRequest<SolanaTransactionParams>(
            method: SolanaMethod.sol_partialSignTransaction.rawValue,
            params: SolanaTransactionParams(type: type, serialized: serialized, serializeConfig: serializeConfig)
        )
        self.provider.send(request: request, response: response)
    }

    /// Promise-based overload of `partialSignTransaction`.
    public func partialSignTransaction(_ serialized: Data, type: SolanaTransactionType, serializeConfig: SolanaSerializeConfig? = nil) -> Promise<SolanaSignedTransaction> {
        return Promise { resolver in
            partialSignTransaction(serialized, type: type, serializeConfig: serializeConfig, response: promiseResolver(resolver))
        }
    }

    // MARK: - Sign Message

    /// Signs a UTF-8 message. Resolves with the 64-byte ed25519 signature.
    public func signMessage(_ message: String, response: @escaping Web3ResponseCompletion<Data>) {
        signMessage(.string(message), response: response)
    }

    /// Signs raw bytes. Resolves with the 64-byte ed25519 signature.
    public func signMessage(_ message: Data, response: @escaping Web3ResponseCompletion<Data>) {
        signMessage(.bytes(TypedArray(message)), response: response)
    }

    /// Promise-based overload of `signMessage` for a UTF-8 message.
    public func signMessage(_ message: String) -> Promise<Data> {
        return Promise { resolver in
            signMessage(message, response: promiseResolver(resolver))
        }
    }

    /// Promise-based overload of `signMessage` for raw bytes.
    public func signMessage(_ message: Data) -> Promise<Data> {
        return Promise { resolver in
            signMessage(message, response: promiseResolver(resolver))
        }
    }

    private func signMessage(_ message: SolanaSignMessageParams.Message, response: @escaping Web3ResponseCompletion<Data>) {
        let request = RPCRequest<SolanaSignMessageParams>(
            method: SolanaMethod.sol_signMessage.rawValue,
            params: SolanaSignMessageParams(message: message)
        )
        self.provider.send(request: request) { (result: Web3Response<TypedArray>) in
            switch result.status {
            case let .success(signature):
                response(Web3Response(status: .success(signature.data)))
            case let .failure(error):
                response(Web3Response(error: error))
            }
        }
    }
}

// MARK: - Magic extension

public extension Magic {
    /// Access Solana methods. `nil` unless `Magic` was created with a `SolanaConfiguration`.
    var solana: SolanaExtension? {
        guard extensionConfigurations.contains(where: { $0 is SolanaConfiguration }) else { return nil }
        return SolanaExtension(rpcProvider: self.rpcProvider)
    }
}
