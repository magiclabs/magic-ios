//
//  UserMessage.swift
//  MagicSDK
//
//  Created by Jerry Liu on 5/17/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation

internal enum UserMethod: String, CaseIterable {

    // Auth
    case magic_auth_get_id_token
    case magic_auth_generate_id_token
    case magic_auth_get_metadata
    case magic_auth_logout
    case magic_auth_update_email
    case magic_auth_is_logged_in
}
