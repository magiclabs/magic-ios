//
//  EthereumTypedData.swift
//  Web3
//
//  Created by Yehor Popovych on 3/19/19.
//  From: https://github.com/Boilertalk/Web3.swift/pull/75/commits/24c556f970115d15d38a4497952767fc4582b2b2
import Foundation
import MagicSDK_Web3


// MARK: - EIP 712
public struct EIP712TypedData: Codable, Equatable {
    public struct `Type`: Codable, Equatable {
        let name: String
        let type: String
    }

    public struct Domain: Codable, Equatable {
        let name: String
        let version: String
        let chainId: Int?
        let verifyingContract: String
    }

    public let types: Dictionary<String, Array<Type>>
    public let primaryType: String
    public let domain: Domain
    public let message: Dictionary<String, JSONValue>

    public init(
        primaryType: String,
        domain: Domain,
        types: Dictionary<String, Array<Type>>,
        message: Dictionary<String, JSONValue>
    ) {
        self.primaryType = primaryType
        self.domain = domain
        self.types = types
        self.message = message
    }
}

public struct SignTypedDataCallParams: Codable, Equatable {
    public let account: EthereumAddress
    public let data: EIP712TypedData

    public init(account: EthereumAddress, data: EIP712TypedData) {
        self.account = account
        self.data = data
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let account = try container.decode(EthereumAddress.self)
        let data = try container.decode(EIP712TypedData.self)
        self.init(account: account, data: data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(account)
        try container.encode(data)
    }
}


// MARK: - EIP 712 legacy
public struct EIP712TypedDataLegacyFields: Codable, Equatable {

    public let type: String
    public let name: String
    public let value: String

    public init(
        type: String,
        name: String,
        value: String
    ) {
        self.type = type
        self.name = name
        self.value = value
    }
}


public struct SignTypedDataLegacyCallParams: Codable, Equatable {
    public let data: [EIP712TypedDataLegacyFields]
    public let account: EthereumAddress

    public init(data: [EIP712TypedDataLegacyFields], account: EthereumAddress) {
        self.data = data
        self.account = account
    }

    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let data = try container.decode(EIP712TypedDataLegacyFields.self)
        let account = try container.decode(EthereumAddress.self)
        self.init(data: [data], account: account)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(data)
        try container.encode(account)
    }
}
