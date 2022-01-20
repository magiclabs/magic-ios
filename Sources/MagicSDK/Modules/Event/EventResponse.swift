//
//  PromiEvents.swift
//  MagicSDK
//
//  Created by Jerry Liu on 7/10/20.
//

import Foundation


internal struct MagicEventResponse<Params: Codable>: Codable {
    
    /// The rpc id
    public let id: Int

    /// The jsonrpc version. Typically 2.0
    public let jsonrpc: String

    /// The result
    public let result: MagicEventResult<Params>

    /// The error
    public let error: Error?

    public struct Error: Swift.Error, Codable {

        /// The error code
        public let code: Int

        /// The error message
        public let message: String
        
        /// Description
        public var localizedDescription: String {
            return "Magic Event Error (\(code)) \(message)"
        }
    }
}

internal struct MagicEventResult<Params: Codable>: Codable {
    let event: String
    let params: Params
}
