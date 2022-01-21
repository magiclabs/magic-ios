//
//  Magic.swift
//  Magic ios SDK
//
//  Created by Jerry Liu on 1/20/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//
import MagicSDK_Web3
import WebKit

/// An instance of the Magic SDK
public class Magic: NSObject {
    
    // MARK: - Module
    public let user: UserModule
    public let auth: AuthModule
    
    // MARK: - Property
    private let overlay: WebViewController
    public var rpcProvider: RpcProvider
    
    /// Shared instance of `Magic`
    public static var shared: Magic!
    
    // MARK: - Initialization
    
    /// Initialize an instance of `Magic`
    ///
    /// - Parameters:
    ///   - apiKey: Your client ID. From https://dashboard.Magic.com
    ///   - ethNetwork: Network setting
    public convenience init(apiKey: String, network: EthNetwork, locale: String = Locale.current.identifier) {
        self.init(urlBuilder: URLBuilder(apiKey: apiKey, network: EthNetworkConfiguration(network: network), locale: locale))
    }
    
    public convenience init(apiKey: String, customNode: CustomNodeConfiguration, locale: String = Locale.current.identifier) {
        self.init(urlBuilder: URLBuilder(apiKey: apiKey, customNode: customNode, locale: locale))
    }
    
    public convenience init(apiKey: String, locale: String = Locale.current.identifier) {
        self.init(urlBuilder: URLBuilder(apiKey: apiKey, network: EthNetworkConfiguration(network: apiKey.contains("live") ? EthNetwork.mainnet: EthNetwork.rinkeby), locale: locale))
    }
    
    private init(urlBuilder: URLBuilder) {
        self.overlay = WebViewController(url: urlBuilder)
        self.rpcProvider = RpcProvider(overlay: self.overlay, urlBuilder: urlBuilder)
        self.user = UserModule(rpcProvider: self.rpcProvider)
        self.auth = AuthModule(rpcProvider: self.rpcProvider)
        super.init()
    }
}

// Handles Specific RpcError
extension Web3Response {
    public var magicAuthError: RpcProvider.ProviderError? {
        switch self.status {
        case .failure(let error):
            return error as? RpcProvider.ProviderError
        case .success:
            return nil
        }
    }
}
