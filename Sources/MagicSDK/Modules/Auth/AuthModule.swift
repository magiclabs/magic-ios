//
//  AuthModule.swift
//  Magic
//
//  Created by Jerry Liu on 3/3/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation
import MagicSDK_Web3
import PromiseKit
import os

public class AuthModule: BaseModule {
    @available(iOS 14.0, *)
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: AuthModule.self)
    )
    
    // MARK: - Login with SMS
    public func loginWithSMS (_ configuration: LoginWithSmsConfiguration, response: @escaping Web3ResponseCompletion<String> ) {
        if #available(iOS 14.0, *) {
            AuthModule.logger.warning("loginWithSMS: \(BaseWarningLog.MA_Method)")
        } else {
            print("loginWithSMS: \(BaseWarningLog.MA_Method)")
        }
        let request = RPCRequest<[LoginWithSmsConfiguration]>(method: AuthMethod.magic_auth_login_with_sms.rawValue, params: [configuration])
        self.provider.send(request: request, response: response)
    }
    
    public func loginWithSMS (_ configuration: LoginWithSmsConfiguration) -> Promise<String> {
        return Promise { resolver in
            loginWithSMS(configuration, response: promiseResolver(resolver))
        }
    }
    
    // MARK: - Login with EmailOTP
    public func loginWithEmailOTP (_ configuration: LoginWithEmailOTPConfiguration, response: @escaping Web3ResponseCompletion<String> ) {
        if #available(iOS 14.0, *) {
            AuthModule.logger.warning("loginWithEmailOTP: \(BaseWarningLog.MA_Method)")
        } else {
            print("loginWithEmailOTP: \(BaseWarningLog.MA_Method)")
        }
        
        let request = RPCRequest<[LoginWithEmailOTPConfiguration]>(method: AuthMethod.magic_auth_login_with_email_otp.rawValue, params: [configuration])
        self.provider.send(request: request, response: response)
    }
    
    public func loginWithEmailOTP (_ configuration: LoginWithEmailOTPConfiguration) -> Promise<String> {
        return Promise { resolver in
            loginWithEmailOTP(configuration, response: promiseResolver(resolver))
        }
    }

    public func cancelLogin() {
        if #available(iOS 14.0, *) {
            AuthModule.logger.warning("cancelLogin: \(BaseWarningLog.MA_Method)")
        } else {
            print("cancelLogin: \(BaseWarningLog.MA_Method)")
        }

        do {
            try self.provider.webViewPresenter.hide()
        } catch let error {
            debugPrint("Failed to dismiss login view due to \(error.localizedDescription)")
        }
    }

    public enum LoginEmailOTPLinkEvent: String {
        case emailNotDeliverable = "email-not-deliverable"
        case emailSent = "email-sent"
        case retry = "retry"
    }
}
