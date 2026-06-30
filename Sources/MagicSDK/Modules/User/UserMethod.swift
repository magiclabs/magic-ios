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
    case magic_get_info
    case magic_auth_logout
    case magic_auth_settings
    case magic_auth_update_email
    case magic_is_logged_in
    case magic_auth_update_phone_number
    case magic_auth_recover_account
    case magic_reveal_key
    case magic_auth_enable_mfa_flow
    case magic_auth_disable_mfa_flow
    case magic_auth_get_metadata
}
