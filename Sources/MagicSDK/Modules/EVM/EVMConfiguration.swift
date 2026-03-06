//
//  EVMConfiguration.swift
//  MagicSDK
//

import Foundation

/// Configuration for switching the active EVM chain.
public struct SwitchChainConfiguration: BaseConfiguration {
    public let chainId: Int

    public init(chainId: Int) {
        self.chainId = chainId
    }
}

/// The network info returned after a successful chain switch.
public struct SwitchChainResult: MagicResponse {
    /// Network identifier — may be a chain name string or nil if the response omits it.
    public let network: SwitchChainNetwork?
}

public struct SwitchChainNetwork: Codable {
    public let rpcUrl: String?
    public let chainId: Int?
    public let chainType: String?
}

/// Configuration for a single EVM network used when registering available chains.
public struct EVMNetworkConfiguration: Codable {
    public let rpcUrl: String
    public let chainId: Int?
    public let isDefault: Bool

    public init(rpcUrl: String, chainId: Int? = nil, isDefault: Bool = false) {
        self.rpcUrl = rpcUrl
        self.chainId = chainId
        self.isDefault = isDefault
    }
}
