//
//  ConnectModule.swift
//
//
//  Created by Jerry Liu on 9/6/22.
//

import Foundation
import MagicSDK_Web3

public class ConnectModule: BaseModule {

    /**
     getWalletInfo
     */
    public func getWalletInfo(response: @escaping Web3ResponseCompletion<WalletInfoResponse>) {

        let request = BasicRPCRequest(method: ConnectMethod.mc_get_wallet_info.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }


    /**
     showWallet
     */
    public func showWallet(response: @escaping Web3ResponseCompletion<Bool>) {

        let request = BasicRPCRequest(method: ConnectMethod.mc_wallet.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }

    /**
     requestUserInfo
     */
    public func requestUserInfo(_ configuration: RequestUserInfoConfiguration = RequestUserInfoConfiguration(), response: @escaping Web3ResponseCompletion<UserInfoResponse>) {

        let request = RPCRequest<[RequestUserInfoConfiguration]>(method: ConnectMethod.mc_request_user_info.rawValue, params: [configuration])

        return self.provider.send(request: request, response: response)
    }

    /**
     disconnect
     */
    public func disconnect(response: @escaping Web3ResponseCompletion<Bool>) {

        let request = BasicRPCRequest(method: ConnectMethod.mc_disconnect.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }
}
