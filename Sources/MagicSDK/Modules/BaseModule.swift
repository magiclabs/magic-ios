//
//  BaseModule.swift
//  Magic Labs
//
//  Created by Jerry Liu on 3/3/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation
import MagicSDK_Web3
import PromiseKit

open class BaseModule {
    
    public let provider: RpcProvider
    public let magicEventCenter = EventCenter()
    
    public init(rpcProvider: RpcProvider) {
        self.provider = rpcProvider
    }
}

public func promiseResolver<T>(_ resolver: Resolver<T>) -> (_ result: Web3Response<T>) -> Void {
    return { result  in
        switch result.status {
        case let .success(value):
            resolver.fulfill(value)
        case let .failure(error):
            resolver.reject(error)
        }
    }
}
