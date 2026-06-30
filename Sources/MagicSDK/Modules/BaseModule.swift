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

    /// Sends a `magic_intermediary_event` back to the relayer, mirroring
    /// `createIntermediaryEvent` in magic-js. Used by event-driven flows
    /// (e.g. submitting OTP when showUI is false).
    /// `args` mirrors the JS SDK: a single scalar value (string, int, bool) or nil.
    /// The relayer casts `eventPayload.args` directly to the expected type — not an array.
    func sendIntermediaryEvent(payloadId: Int, eventType: String, arg: Any? = nil) {
        struct IntermediaryParams: Codable {
            let payloadId: Int
            let eventType: String
            let args: AnyValue?
        }
        let argValue: AnyValue? = {
            guard let arg = arg else { return nil }
            if let s = arg as? String { return AnyValue(valueType: .string(s)) }
            if let i = arg as? Int    { return AnyValue(valueType: .int(i)) }
            if let b = arg as? Bool   { return AnyValue(valueType: .bool(b)) }
            return nil
        }()
        let params = IntermediaryParams(payloadId: payloadId, eventType: eventType, args: argValue)
        let request = RPCRequest<[IntermediaryParams]>(method: "magic_intermediary_event", params: [params])
        provider.send(request: request) { (_: Web3Response<String?>) in }
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
