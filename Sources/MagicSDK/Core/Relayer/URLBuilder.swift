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

    init(apiKey: String, customNode: CustomNodeConfiguration? = nil, ethNetwork: EthNetwork? = nil, locale: String, productType: ProductType) {
        let options = paramsEncodable(apiKey: apiKey, customNode: customNode, ethNetwork: ethNetwork, locale: locale, productType: productType)

        let data = try! JSONEncoder().encode(options)
        self.init(data: data, host: URLBuilder.host, apiKey: apiKey)
    }

    init(apiKey: String, network: EthNetwork, locale: String) {
        let options = EthNetworkOptions(apiKey: apiKey, network: network, locale: locale)
        let data = try! JSONEncoder().encode(options)
        self.init(data: data, host: URLBuilder.host, apiKey: apiKey)
    }

    private init(data: Data, host: String, apiKey: String, productType: ProductType) {
        let jsonString = String(data: data, encoding: .utf8)!
        let string = jsonString.replacingOccurrences(of: "\\", with: "")
        // Encode instantiate option to params
        self.apiKey = apiKey
        self.encodedParams = btoa(jsonString: string)
        self.url = "\(host)/send/?params=\(self.encodedParams)"
    }

    // MARK: - Options structs
    struct paramsEncodable: Encodable {
        let API_KEY: String
        let host = URLBuilder.host
        let sdk = "magic-sdk-ios"
        let ETH_NETWORK: String
        let locale: String
        let bundleId = Bundle.main.bundleIdentifier
        init(apiKey: String, network: EthNetwork, locale: String) {
            self.ETH_NETWORK = network.rawValue
            self.API_KEY = apiKey
            self.locale = locale
        }

        enum CodingKeys: String, CodingKey {
            case sdk, bundleId, API_KEY, host, ETH_NETWORK, ext
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode("magic-sdk-ios", forKey: .sdk)
            try container.encode(Bundle.main.bundleIdentifier, forKey: .bundleId)
            try container.encode(self.API_KEY, forKey: .API_KEY)
            try container.encode(URLBuilder.host, forKey: .host)

            /// Network
            if (customNode != nil) {
                try container.encode(customNode, forKey: .ETH_NETWORK)
            }
            if (ethNetwork != nil) {
                try container.encode(ethNetwork?.rawValue, forKey: .ETH_NETWORK)
            }

            try container.encode(ExtensionObject(productType: productType), forKey: .ext)
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


// MARK: -- Extension
struct ExtensionObject: Encodable {

    let productType: ProductType

    init(productType: ProductType) {
        self.productType = productType
    }

    enum CodingKeys: String, CodingKey {
        case connect
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch productType {
        case .MC:
            try container.encode(MCConfig(), forKey: .connect)
            break
        default:
            break
        }

    }
}

internal struct MCConfig: Encodable {
    let mc = true
}
