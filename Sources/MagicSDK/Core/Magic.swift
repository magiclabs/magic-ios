//
//  Magic.swift
//  Magic ios SDK
//
//  Created by Jerry Liu on 1/20/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//
import MagicSDK_Web3
import WebKit


internal enum ProductType{
    case MA
    case MC
}

/// An instance of the Magic SDK
public class Magic: MagicCore {

    // MARK: - Module
    public let user: UserModule
    public let auth: AuthModule

    /// Shared instance of `Magic`
    public static var shared: Magic!

    // MARK: - Initialization

    /// Initialize an instance of `Magic`
    ///
    /// - Parameters:
    ///   - apiKey: Your client ID. From https://dashboard.Magic.com
    ///   - ethNetwork: Network setting
    public convenience init(apiKey: String, network: EthNetwork, locale: String = Locale.current.identifier) {
        self.init(urlBuilder: URLBuilder(apiKey: apiKey, locale: locale, productType: .MA))
    }

    public convenience init(apiKey: String, customNode: CustomNodeConfiguration, locale: String = Locale.current.identifier) {
        let urlBuilder = URLBuilder(apiKey: apiKey, customNode: customNode, locale: locale, productType: ProductType.MA)
        self.init(urlBuilder: urlBuilder)
    }

    public convenience init(apiKey: String, locale: String = Locale.current.identifier) {
        self.init(urlBuilder: URLBuilder(apiKey: apiKey, locale: locale, productType: .MA))
    }

    /// Core constructor
    private init(urlBuilder: URLBuilder) {
        let rpcProvider = RpcProvider(urlBuilder: urlBuilder)
        self.user = UserModule(rpcProvider: rpcProvider)
        self.auth = AuthModule(rpcProvider: rpcProvider)
        super.init(rpcProvider: rpcProvider)
    }
}

/// An instance of the Magic SDK
public class MagicConnect: MagicCore {

    public let connect: ConnectModule

    /// Shared instance of `Magic`
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
        let rpcProvider = RpcProvider(urlBuilder: urlBuilder)
        self.connect = ConnectModule(rpcProvider: rpcProvider)
        super.init(rpcProvider: rpcProvider)
    }
}

public class MagicCore: NSObject {
    
    public var rpcProvider: RpcProvider
    
    internal init(rpcProvider: RpcProvider) {
        self.rpcProvider = rpcProvider
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
