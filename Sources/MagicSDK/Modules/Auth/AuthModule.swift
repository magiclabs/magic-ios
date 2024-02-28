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

public class AuthModule: BaseModule {
    // MARK: - Login with SMS
    public func loginWithSMS (_ configuration: LoginWithSmsConfiguration, response: @escaping Web3ResponseCompletion<String> ) {
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
        let request = RPCRequest<[LoginWithEmailOTPConfiguration]>(method: AuthMethod.magic_auth_login_with_email_otp.rawValue, params: [configuration])
        self.provider.send(request: request, response: response)
    }
    
    public func loginWithEmailOTP (_ configuration: LoginWithEmailOTPConfiguration) -> Promise<String> {
        return Promise { resolver in
            loginWithEmailOTP(configuration, response: promiseResolver(resolver))
        }
    }
    
    public enum LoginEmailOTPLinkEvent: String {
        case emailNotDeliverable = "email-not-deliverable"
        case emailSent = "email-sent"
        case retry = "retry"
    }
}
