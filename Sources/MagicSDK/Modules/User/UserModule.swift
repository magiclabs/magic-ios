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
            Get Metadata
     */
    public func getMetadata(response: @escaping Web3ResponseCompletion<UserMetadata>) {
        let request = BasicRPCRequest(method: UserMethod.magic_auth_get_metadata.rawValue, params: [])
        return self.provider.send(request: request, response: response)
    }
    
    public func getMetadata() -> Promise<UserMetadata>  {
        return Promise { resolver in
            getMetadata(response: promiseResolver(resolver))
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
}
