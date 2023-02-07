//
//  UserResponse.swift
//  Magic
//
//  Created by Jerry Liu on 3/16/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation
import MagicSDK_Web3

public protocol MagicResponse: Codable {}

/// Get Id Token configuration
public struct UserMetadata: MagicResponse {
    
    public let issuer: String?
    public let publicAddress: String?
    public let email: String?
}
