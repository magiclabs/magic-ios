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
    public let apiKey: String

    init(apiKey: String, customNode: CustomNodeConfiguration? = nil, network: EthNetwork? = nil, locale: String) {

        let data = try! JSONEncoder().encode(
            UrlParamsEncodable(
                apiKey: apiKey,
                ethNetwork: network,
                customNode: customNode,
                locale: locale
            )
        )

        self.init(data: data, host: URLBuilder.host, apiKey: apiKey)
    }

    private init(data: Data, host: String, apiKey: String) {
        
        let jsonString = String(data: data, encoding: .utf8)!
        let sanitizedJsonString = jsonString.replacingOccurrences(of: "\\", with: "")
        
        // Encode instantiate option to params
        self.apiKey = apiKey
        self.encodedParams = btoa(jsonString: sanitizedJsonString)
        
        self.url = "\(host)/send/?params=\(self.encodedParams)"
    }

    // MARK: - UrlParamsEncodable
    struct UrlParamsEncodable: Encodable {
        
        let apiKey: String
        let locale: String
        let customNode: CustomNodeConfiguration?
        let ethNetwork: EthNetwork?
        
        init(apiKey: String, ethNetwork: EthNetwork?, customNode: CustomNodeConfiguration?, locale: String) {
            self.apiKey = apiKey
            self.locale = locale
            self.customNode = customNode
            self.ethNetwork = ethNetwork
        }

        enum CodingKeys: String, CodingKey {
            case apiKey = "API_KEY"
            case ethNetwork = "ETH_NETWORK"
            case bundleId, host, sdk
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode("magic-sdk-ios", forKey: .sdk)
            try container.encode(Bundle.main.bundleIdentifier, forKey: .bundleId)
            
            try container.encode(apiKey, forKey: .apiKey)
            try container.encode(URLBuilder.host, forKey: .host)


            if let node = customNode {
                try container.encode(node, forKey: .ethNetwork)
            }
            if let network = ethNetwork {
                try container.encode(network.rawValue, forKey: .ethNetwork)
            }
        }
    }
}

// MARK: -- Network
public struct CustomNodeConfiguration: Encodable {
    let rpcUrl: String
    let chainId: Int?

    public init (rpcUrl: String, chainId: Int? = nil) {
        self.rpcUrl = rpcUrl
        self.chainId = chainId
    }
}
