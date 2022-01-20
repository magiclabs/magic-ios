//
//  URLBuilder.swift
//  Magic
//
//  Created by Jerry Liu on 3/16/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation

// MARK: - URLBuilder init
//
// Construct a URI with options encoded
//
public struct URLBuilder {
    
    let encodedParams, url: String
    static let host = "https://box.magic.link"
//  static let host = "http://192.168.0.106:3016"
    
    public let apiKey: String

    init(apiKey: String, customNode: CustomNodeConfiguration, locale: String) {
        let options = CustomNodeOptions(apiKey: apiKey, customNode: customNode, locale: locale)
    
        let data = try! JSONEncoder().encode(options)
        self.init(data: data, host: URLBuilder.host, apiKey: apiKey)
    }
    
    init(apiKey: String, network: EthNetworkConfiguration, locale: String) {
        let options = EthNetworkOptions(apiKey: apiKey, network: network, locale: locale)
        let data = try! JSONEncoder().encode(options)
        self.init(data: data, host: URLBuilder.host, apiKey: apiKey)
    }
    
    private init(data: Data, host: String, apiKey: String) {
        let jsonString = String(data: data, encoding: .utf8)!
        let string = jsonString.replacingOccurrences(of: "\\", with: "")
        // Encode instantiate option to params
        self.apiKey = apiKey
        self.encodedParams = btoa(jsonString: string)
        self.url = "\(host)/send/?params=\(self.encodedParams)"
    }

    // MARK: - Options structs
    // Here, Struct is more preferable here. Even though, it can't inherit from classes
    // Using class will create more duplicate code as all the sub-class
    // needs to be override encode function to encode additional property
    struct EthNetworkOptions: Encodable {
        let API_KEY: String
        let host = URLBuilder.host
        let sdk = "magic-sdk-ios"
        let ETH_NETWORK: EthNetworkConfiguration
        let locale: String
        init(apiKey: String, network: EthNetworkConfiguration, locale: String) {
            self.ETH_NETWORK = network
            self.API_KEY = apiKey
            self.locale = locale
        }
    }

    struct CustomNodeOptions: Encodable {
        let API_KEY: String
        let host = URLBuilder.host
        let sdk = "magic-sdk-ios"
        let ETH_NETWORK: CustomNodeConfiguration
        let locale: String
        init(apiKey: String, customNode: CustomNodeConfiguration, locale: String) {
            self.ETH_NETWORK = customNode
            self.API_KEY = apiKey
            self.locale = locale
        }
    }
}

public struct CustomNodeConfiguration: Encodable {
    let rpcUrl: String
    let chainId: Int?
    
    public init (rpcUrl: String, chainId: Int? = nil) {
        self.rpcUrl = rpcUrl
        self.chainId = chainId
    }
}

internal struct EthNetworkConfiguration: Encodable {
    let network: String
    
    init (network: EthNetwork) {
        self.network = network.rawValue
    }
}
