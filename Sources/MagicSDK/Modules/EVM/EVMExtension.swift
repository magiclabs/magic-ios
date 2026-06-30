//
//  EVMExtension.swift
//  MagicSDK
//

import Foundation
import MagicSDK_Web3
import PromiseKit

/// EVM extension providing multi-chain support, including dynamic chain switching.
/// Mirrors the `@magic-ext/evm` package in magic-js.
public class EVMExtension: BaseModule {

    // MARK: - Switch Chain

    /// Switches the active EVM chain to the one identified by `chainId`.
    ///
    /// - Parameters:
    ///   - configuration: Contains the target `chainId`.
    ///   - response: Completion handler called with the new network info or an error.
    public func switchChain(_ configuration: SwitchChainConfiguration, response: @escaping Web3ResponseCompletion<SwitchChainResult>) {
        let request = RPCRequest<[SwitchChainConfiguration]>(
            method: EVMMethod.evm_switchChain.rawValue,
            params: [configuration]
        )
        self.provider.send(request: request, response: response)
    }

    /// Promise-based overload of `switchChain`.
    public func switchChain(_ configuration: SwitchChainConfiguration) -> Promise<SwitchChainResult> {
        return Promise { resolver in
            switchChain(configuration, response: promiseResolver(resolver))
        }
    }
}

// MARK: - Magic extension

public extension Magic {
    /// Access EVM-specific methods such as `switchChain`.
    var evm: EVMExtension {
        return EVMExtension(rpcProvider: self.rpcProvider)
    }
}
