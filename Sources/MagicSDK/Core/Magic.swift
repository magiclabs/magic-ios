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
        let urlBuilder = URLBuilder(apiKey: apiKey, ethNetwork: network, locale: locale, productType: ProductType.MA)
        self.init(urlBuilder: urlBuilder)
    }
    
    public convenience init(apiKey: String, customNode: CustomNodeConfiguration, locale: String = Locale.current.identifier) {
        let urlBuilder = URLBuilder(apiKey: apiKey, customNode: customNode, locale: locale, productType: ProductType.MA)
        self.init(urlBuilder: urlBuilder)
    }
    
    public convenience init(apiKey: String, locale: String = Locale.current.identifier) {
        let urlBuilder = URLBuilder(apiKey: apiKey, ethNetwork: EthNetwork.mainnet, locale: locale, productType: ProductType.MA)
        self.init(urlBuilder: urlBuilder)
    }
    
    /// Core constructor
    private init(urlBuilder: URLBuilder) {
        self.rpcProvider = RpcProvider(urlBuilder: urlBuilder)
        self.user = UserModule(rpcProvider: self.rpcProvider)
        self.auth = AuthModule(rpcProvider: self.rpcProvider)
        super.init()
    }
}

/// An instance of the Magic SDK
public class MagicConnect: NSObject {
    
    public let connect: ConnectModule

    public var rpcProvider: RpcProvider
    
    public static var shared: MagicConnect!

    public convenience init(apiKey: String) {
        let urlBuilder = URLBuilder(apiKey: apiKey, ethNetwork: EthNetwork.mainnet, locale: "en_US", productType: ProductType.MC)
        self.init(urlBuilder: urlBuilder)
    }
    
    public convenience init(apiKey: String, network: EthNetwork) {
        let urlBuilder = URLBuilder(apiKey: apiKey, ethNetwork: network, locale: "en_US", productType: ProductType.MC)
        self.init(urlBuilder: urlBuilder)
    }

    private init(urlBuilder: URLBuilder) {
        self.rpcProvider = RpcProvider(urlBuilder: urlBuilder)
        self.connect = ConnectModule(rpcProvider: self.rpcProvider)
        super.init()
    }
}

enum ProductType{
    case MA
    case MC
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
