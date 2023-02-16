//
//  ConnectResponse.swift
//
//
//  Created by Wentao Liu on 9/22/22.
//

import Foundation

public struct UserInfoResponse: MagicResponse {

    public let email: String?
}

public struct WalletInfoResponse: MagicResponse {
    public let walletType: String?
}

public struct ConnectWithUIResponse: MagicResponse {
    public let accounts: [String]
}
