//
//  Type.swift
//  Magic
//
//  Created by Jerry Liu on 2/6/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation

enum InboundMessageType: String, CaseIterable {
    case MAGIC_HANDLE_RESPONSE
    case MAGIC_OVERLAY_READY
    case MAGIC_SHOW_OVERLAY
    case MAGIC_HIDE_OVERLAY
    case MAGIC_HANDLE_EVENT
    case MAGIC_SEND_PRODUCT_ANNOUNCEMENT
    case MAGIC_PONG
}

enum OutboundMessageType: String, CaseIterable {
    case MAGIC_HANDLE_REQUEST
    case MAGIC_PING
}

struct MagicRequestData<T: Codable>: Codable {
    
    let msgType: String
    let payload: T
    let rt: String?
    let jwt: String?
}

struct MagicResponseData<T: Codable>: Codable {
    
    let msgType: String
    let response: T
    let rt: String?
}
