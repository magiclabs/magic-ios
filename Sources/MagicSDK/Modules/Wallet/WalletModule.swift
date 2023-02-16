//
//  WalletModule.swift
//
//
//  Created by Arian Flores on 02/16/23.
//

import Foundation
import MagicSDK_Web3

public class WalletModule: BaseModule {
    
    /**
     connectWithUI
     */
    public func connectWithUI(response: @escaping Web3ResponseCompletion<ConnectWithUIResponse>) {

        let request = BasicRPCRequest(method: WalletMethod.mc_login.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }
    
    /**
     showUI
     */
    public func showUI(response: @escaping Web3ResponseCompletion<Bool>) {

        let request = BasicRPCRequest(method: WalletMethod.mc_wallet.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }

    /**
     getInfo
     */
    public func getInfo(response: @escaping Web3ResponseCompletion<WalletInfoResponse>) {

        let request = BasicRPCRequest(method: WalletMethod.mc_get_wallet_info.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }


    /**
     requestUserInfoWithUI
     */
    public func requestUserInfoWithUI(_ configuration: RequestUserInfoWithUIConfiguration? = nil, response: @escaping Web3ResponseCompletion<UserInfoResponse>) {

        let request = RPCRequest<[RequestUserInfoWithUIConfiguration?]>(method: WalletMethod.mc_request_user_info.rawValue, params: (configuration != nil) ? [configuration]: [])

        return self.provider.send(request: request, response: response)
    }

    /**
     disconnect
     */
    public func disconnect(response: @escaping Web3ResponseCompletion<Bool>) {

        let request = BasicRPCRequest(method: WalletMethod.mc_disconnect.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }
}
