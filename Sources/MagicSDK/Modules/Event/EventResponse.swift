//
//  PromiEvents.swift
//  MagicSDK
//
//  Created by Jerry Liu on 7/10/20.
//

import Foundation


internal struct MagicEventResponse<ResultType: Codable>: Codable {
    public let id: Int?
    public let jsonrpc: String
    public let result: MagicEventResult<ResultType?>
    public let error: Error?
    
    // Error struct remains the same
    public struct Error: Swift.Error, Codable {
        public let code: Int
        public let message: String
        public var localizedDescription: String {
            return "Magic Event Error (\(code)) \(message)"
        }
    }
}

internal struct MagicEventResult<Params: Codable>: Codable {
    let event: String?
    let params: Params?
    let product_announcement: String?
}
