//
//  ConnectMethod.swift
//
//
//  Created by Jerry Liu on 9/6/22.
//

import Foundation

internal enum WalletMethod: String, CaseIterable {

    // MC
    case mc_login = "eth_requestAccounts"
    case mc_get_wallet_info
    case mc_wallet
    case mc_request_user_info
    case mc_disconnect
}
