//
//  WalletModule.swift
//
//
//  Created by Arian Flores on 02/16/23.
//

import Foundation
import MagicSDK_Web3
import os

public class WalletModule: BaseModule {
    @available(iOS 14.0, *)
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: WalletModule.self)
    )
    
    
    /**
     connectWithUI
     */
    public func connectWithUI(response: @escaping Web3ResponseCompletion<[String]>) {
        if #available(iOS 14.0, *) {
            WalletModule.logger.warning("connectWithUI: \(BaseWarningLog.MC_Method)")
        } else {
            print("connectWithUI: \(BaseWarningLog.MC_Method)")
        }

        let request = BasicRPCRequest(method: WalletMethod.mc_login.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }
    
    /**
     showUI
     */
    public func showUI(response: @escaping Web3ResponseCompletion<Bool>) {
        if #available(iOS 14.0, *) {
            WalletModule.logger.warning("showUI: \(BaseWarningLog.MC_Method)")
        } else {
            print("showUI: \(BaseWarningLog.MC_Method)")
        }
        
        let request = BasicRPCRequest(method: WalletMethod.mc_wallet.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }

    /**
     getInfo
     */
    public func getInfo(response: @escaping Web3ResponseCompletion<WalletInfoResponse>) {
        if #available(iOS 14.0, *) {
            WalletModule.logger.warning("getInfo: \(BaseWarningLog.MC_Method)")
        } else {
            print("getInfo: \(BaseWarningLog.MC_Method)")
        }
        
        let request = BasicRPCRequest(method: WalletMethod.mc_get_wallet_info.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }


    /**
     requestUserInfoWithUI
     */
    public func requestUserInfoWithUI(_ configuration: RequestUserInfoWithUIConfiguration? = nil, response: @escaping Web3ResponseCompletion<UserInfoResponse>) {
        if #available(iOS 14.0, *) {
            WalletModule.logger.warning("requestUserInfoWithUI: \(BaseWarningLog.MC_Method)")
        } else {
            print("requestUserInfoWithUI: \(BaseWarningLog.MC_Method)")
        }
        
        let request = RPCRequest<[RequestUserInfoWithUIConfiguration?]>(method: WalletMethod.mc_request_user_info.rawValue, params: (configuration != nil) ? [configuration]: [])

        return self.provider.send(request: request, response: response)
    }

    /**
     disconnect
     */
    public func disconnect(response: @escaping Web3ResponseCompletion<Bool>) {
        if #available(iOS 14.0, *) {
            WalletModule.logger.warning("disconnect: \(BaseWarningLog.MC_Method)")
        } else {
            print("disconnect: \(BaseWarningLog.MC_Method)")
        }
        
        let request = BasicRPCRequest(method: WalletMethod.mc_disconnect.rawValue, params: [])

        return self.provider.send(request: request, response: response)
    }
}
