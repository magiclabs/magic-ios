//
//  AuthMessage.swift
//  MagicSDK
//
//  Created by Jerry Liu on 5/17/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation

internal enum AuthMethod: String, CaseIterable {

    // Auth
    case magic_auth_login_with_magic_link
    case magic_auth_login_with_sms
    case magic_auth_login_with_email_otp
}
