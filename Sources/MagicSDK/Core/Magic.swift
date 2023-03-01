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
    // MARK: - Log Message Warning
    public let MA_EXTENSION_ONLY_MSG = "This extension only works with Magic Auth API Keys"
    
    // MARK: - Modules
    public let user: UserModule
    public let auth: AuthModule
    public let wallet: WalletModule
    
    // MARK: - Property
   public var rpcProvider: RpcProvider

    /// Shared instance of `Magic`
    public static var shared: Magic!

    // MARK: - Initialization

    /// Initialize an instance of `Magic`
    ///
    /// - Parameters:
    ///   - apiKey: Your client ID. From https://dashboard.Magic.com
    ///   - ethNetwork: Etherum Network setting (ie. mainnet or goerli)
    ///   - customNode: A custom RPC node 
    public convenience init(apiKey: String, ethNetwork: EthNetwork, locale: String = Locale.current.identifier) {
        self.init(urlBuilder: URLBuilder(apiKey: apiKey, network: ethNetwork, locale: locale))
    }

    public convenience init(apiKey: String, customNode: CustomNodeConfiguration, locale: String = Locale.current.identifier) {
        self.init(urlBuilder: URLBuilder(apiKey: apiKey, customNode: customNode, locale: locale))
    }

    public convenience init(apiKey: String, locale: String = Locale.current.identifier) {
        self.init(urlBuilder: URLBuilder(apiKey: apiKey, network: EthNetwork.mainnet, locale: locale))
    }

    /// Core constructor
    private init(urlBuilder: URLBuilder) {
         self.rpcProvider = RpcProvider(urlBuilder: urlBuilder)
        
         self.user = UserModule(rpcProvider: self.rpcProvider)
         self.auth = AuthModule(rpcProvider: self.rpcProvider)
         self.wallet = WalletModule(rpcProvider: self.rpcProvider)
        
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
