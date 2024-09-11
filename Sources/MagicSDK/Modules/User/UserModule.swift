//
//  PhantomUser.swift
//
//  Created by Jerry Liu on 3/2/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation
import MagicSDK_Web3
import PromiseKit

public class UserModule: BaseModule {
    /**
     GetIdToken
     */
    public func getIdToken(_ configuration: GetIdTokenConfiguration? = nil, response: @escaping Web3ResponseCompletion<String>) {
        let request = RPCRequest<[GetIdTokenConfiguration?]>(method: UserMethod.magic_auth_get_id_token.rawValue, params: [configuration])

        return self.provider.send(request: request, response: response)
    }
    
    public func getIdToken(_ configuration: GetIdTokenConfiguration? = nil) -> Promise<String>  {
        return Promise { resolver in
            getIdToken(configuration, response: promiseResolver(resolver))
        }
    }
    
    /**
            Generate Id Token
     */
    public func generateIdToken(_ configuration: GenerateIdTokenConfiguration? = nil, response: @escaping Web3ResponseCompletion<String>) {
        let request = RPCRequest<[GenerateIdTokenConfiguration?]>(method: UserMethod.magic_auth_generate_id_token.rawValue, params: [configuration])
        
        return self.provider.send(request: request, response: response)
    }
    
    public func generateIdToken(_ configuration: GenerateIdTokenConfiguration? = nil) -> Promise<String> {
        return Promise { resolver in
            generateIdToken(configuration, response: promiseResolver(resolver))
        }
    }
    
    
    /**
            Get Info
     */
    public func getInfo(response: @escaping Web3ResponseCompletion<UserInfo>) {
        let request = BasicRPCRequest(method: UserMethod.magic_get_info.rawValue, params: [])
        return self.provider.send(request: request, response: response)
    }
    
    public func getInfo() -> Promise<UserInfo>  {
        return Promise { resolver in
            getInfo(response: promiseResolver(resolver))
        }
    }
    
    /**
                IsLogged In
     */
    public func isLoggedIn(response: @escaping Web3ResponseCompletion<Bool>) {
        let request = BasicRPCRequest(method: UserMethod.magic_auth_is_logged_in.rawValue, params: [])
        self.provider.send(request: request, response: response)
    }
    
    public func isLoggedIn() -> Promise<Bool>  {
        return Promise { resolver in
            isLoggedIn(response: promiseResolver(resolver))
        }
    }
    
    /**
     *       Update Email
     */
    public func updateEmail(_ configuration: UpdateEmailConfiguration, response: @escaping Web3ResponseCompletion<Bool>) {
        let request = RPCRequest<[UpdateEmailConfiguration]>(method: UserMethod.magic_auth_update_email.rawValue, params: [configuration])
        
        return self.provider.send(request: request, response: response)
    }
    
    public func updateEmail(_ configuration: UpdateEmailConfiguration) -> Promise<Bool> {
        return Promise { resolver in
            updateEmail(configuration, response: promiseResolver(resolver))
        }
    }
    
    public func updateEmail(_ configuration: UpdateEmailConfiguration, eventLog: Bool) -> MagicEventPromise<Bool> {
        return MagicEventPromise (eventCenter: self.magicEventCenter, eventLog: eventLog){ resolver in
            self.updateEmail(configuration, response: promiseResolver(resolver))
        }
    }
    
    /**
            Logout
     */
    public func logout (response: @escaping Web3ResponseCompletion<Bool>) {
        let request = BasicRPCRequest(method: UserMethod.magic_auth_logout.rawValue, params: [])
        self.provider.send(request: request, response: response)
    }
    
    public func logout() -> Promise<Bool>  {
        return Promise { resolver in
            logout(response: promiseResolver(resolver))
        }
    }
    /**
        showSettings
     */
    public func showSettings(response: @escaping Web3ResponseCompletion<UserInfo>) {
        let request = BasicRPCRequest(method: UserMethod.magic_auth_settings.rawValue, params: [])
        self.provider.send(request: request, response: response)
    }
    
    public func showSettings() -> Promise<UserInfo> {
        return Promise { resolver in
            showSettings(response: promiseResolver(resolver))
        }
    }
    
    /**
        updatePhoneNumber
     */
    public func updatePhoneNumber(response: @escaping Web3ResponseCompletion<String>) {
        let request = BasicRPCRequest(method: UserMethod.magic_auth_update_phone_number.rawValue, params: [])
        self.provider.send(request: request, response: response)
    }
    
    public func updatePhoneNumber() -> Promise<String> {
        return Promise { resolver in
            updatePhoneNumber(response: promiseResolver(resolver))
        }
    }        
    
    /**
        recoverAccount
     */
    public func recoverAccount(_ configuration: RecoverAccountConfiguration, response: @escaping Web3ResponseCompletion<Bool>) {
        let request = RPCRequest<[RecoverAccountConfiguration]>(method: UserMethod.magic_auth_recover_account.rawValue, params: [configuration])
        
        return self.provider.send(request: request, response: response)
    }
    
    public func recoverAccount(_ configuration: RecoverAccountConfiguration) -> Promise<Bool> {
        return Promise { resolver in
            recoverAccount(configuration, response: promiseResolver(resolver))
        }
    }

    /**
        revealPrivateKey
     */
     public func revealPrivateKey(response: @escaping Web3ResponseCompletion<Bool>) {
        let request = BasicRPCRequest(method: UserMethod.magic_reveal_key.rawValue, params: [])
        self.provider.send(request: request, response: response)
     }

     public func revealPrivateKey() -> Promise<Bool> {
        return Promise { resolver in
            revealPrivateKey(response: promiseResolver(resolver))
        }
     }
}
