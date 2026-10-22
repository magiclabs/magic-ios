//
//  MultichainExtension.swift
//  MagicSDK
//

import Foundation
import MagicSDK_Web3
import PromiseKit

internal enum MultichainMethod: String {
    case magic_get_multichain_public_address
    case magic_reveal_key
}

/// Base class for non-EVM chain extensions, such as `SolanaExtension` in the
/// `MagicExt-Solana` package. Mirrors `MultichainExtension` in `@magic-sdk/provider`.
open class MultichainExtension: BaseModule {

    /// The chain type sent to the relayer, e.g. `SOLANA` or `BITCOIN`.
    public let chain: String

    public init(rpcProvider: RpcProvider, chain: String) {
        self.chain = chain
        super.init(rpcProvider: rpcProvider)
    }

    struct ChainParams: Codable {
        let chain: String
    }

    // MARK: - Get Public Address

    /// Gets the user's public address on this chain.
    public func getPublicAddress(response: @escaping Web3ResponseCompletion<String>) {
        let request = RPCRequest<[ChainParams]>(
            method: MultichainMethod.magic_get_multichain_public_address.rawValue,
            params: [ChainParams(chain: chain)]
        )
        self.provider.send(request: request, response: response)
    }

    /// Promise-based overload of `getPublicAddress`.
    public func getPublicAddress() -> Promise<String> {
        return Promise { resolver in
            getPublicAddress(response: promiseResolver(resolver))
        }
    }

    // MARK: - Reveal Private Key

    /// Shows the Magic UI that reveals the user's private key for this chain.
    public func revealPrivateKey(response: @escaping Web3ResponseCompletion<Bool>) {
        let request = RPCRequest<[ChainParams]>(
            method: MultichainMethod.magic_reveal_key.rawValue,
            params: [ChainParams(chain: chain)]
        )
        self.provider.send(request: request, response: response)
    }

    /// Promise-based overload of `revealPrivateKey`.
    public func revealPrivateKey() -> Promise<Bool> {
        return Promise { resolver in
            revealPrivateKey(response: promiseResolver(resolver))
        }
    }
}
