//
//  Web3Extension.swift
//  Magic
//
//  Created by Jerry Liu on 2/9/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation
import MagicSDK_Web3
import PromiseKit

// MARK: - web3 extension with closure
public extension Web3.Eth {
    
    func getCoinbase(response: @escaping Web3.Web3ResponseCompletion<EthereumAddress>) {
        let req = BasicRPCRequest(
            id: properties.rpcId,
            jsonrpc: Web3.jsonrpc,
            method: "eth_coinbase",
            params: []
        )
        properties.provider.send(request: req, response: response)
    }
    
    func sign(from: EthereumAddress, message: EthereumData, response: @escaping Web3.Web3ResponseCompletion<EthereumData>) {
        let req = RPCRequest<EthereumValue>(
            id: properties.rpcId,
            jsonrpc: Web3.jsonrpc,
            method: "eth_sign",
            params: [from, message]
        )
        properties.provider.send(request: req, response: response)
    }
    
    func signTypedDataV1(
        data: [EIP712TypedDataLegacyFields],
        account: EthereumAddress,
        response: @escaping Web3ResponseCompletion<EthereumData>
    ) {
        let req = RPCRequest<SignTypedDataLegacyCallParams>(
            id: properties.rpcId,
            jsonrpc: Web3.jsonrpc,
            method: "eth_signTypedData",
            params: SignTypedDataLegacyCallParams(
                data: data, account: account
            )
        )
        properties.provider.send(request: req, response: response)
    }
    
    func signTypedDataV3(
        account: EthereumAddress,
        data: EIP712TypedData,
        response: @escaping Web3ResponseCompletion<EthereumData>
    ) {
        let req = RPCRequest<SignTypedDataCallParams>(
            id: properties.rpcId,
            jsonrpc: Web3.jsonrpc,
            method: "eth_signTypedData_v3",
            params: SignTypedDataCallParams(
                account: account, data: data
            )
        )
        properties.provider.send(request: req, response: response)
    }
}

// MARK: - web3 extension Promises
///
public extension Web3.Eth {
    
    func getCoinbase() -> Promise<EthereumAddress> {
        return Promise { resolver in
            getCoinbase(response: promiseResolver(resolver))
        }
    }
    
    func sign(from: EthereumAddress, message: EthereumData) -> Promise<EthereumData> {
        return Promise { resolver in
            sign(from: from, message: message, response: promiseResolver(resolver))
        }
    }
    
    func signTypedDataLegacy(
        account: EthereumAddress, data: [EIP712TypedDataLegacyFields]) -> Promise<EthereumData> {
        return Promise { resolver in
            signTypedDataV1(data: data, account: account, response: promiseResolver(resolver))
        }
    }
    
    func signTypedData(
        account: EthereumAddress, data: EIP712TypedData) -> Promise<EthereumData> {
        return Promise { resolver in
            signTypedDataV3(account: account, data: data, response: promiseResolver(resolver))
        }
    }
}

public extension RPCRequest {
    
    init(method: String, params: Params) {
        self = RPCRequest(id: generateRandomId(), jsonrpc: "2.0", method: method, params: params)
    }
}

/// Represents distinct Ethereum Networks
///
/// Note: Conforms to Hashable so that we can use these as a Dictionary key
public enum EthNetwork: String {
    case mainnet
    case kovan
    case rinkeby
    case ropsten
}
