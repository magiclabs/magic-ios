//
//  PromiEvents.swift
//  MagicSDK
//
//  Created by Jerry Liu on 7/10/20.
//

import Foundation

enum IDType: Codable {
    case string(String)
    case int(Int)
    case none

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let str = try? container.decode(String.self) {
            self = .string(str)
        } else if let int = try? container.decode(Int.self) {
            self = .int(int)
        } else {
            self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .string(let str):
                try container.encode(str)
            case .int(let int):
                try container.encode(int)
            case .none:
                try container.encodeNil()
        }
    }
}


internal struct MagicEventResponse<ResultType: Codable>: Codable {
    public let id: IDType?
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
