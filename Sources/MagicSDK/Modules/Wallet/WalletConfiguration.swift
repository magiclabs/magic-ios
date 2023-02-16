//
//  WalletConfiguration.swift
//
//
//  Created by Arian Flores on 02/16/23.
//

import Foundation

public enum WalletUserInfoEmailOptions: String, Codable {
    case required, optional
}

public struct RequestUserInfoWithUIConfiguration: BaseConfiguration {
    let scope: WalletUserInfoScope
    
    public init(scope: WalletUserInfoScope) {
        self.scope = scope
    }
    
    enum CodingKeys: String, CodingKey {
        case scope
    }
}

public struct WalletUserInfoScope: Codable {
    var email: WalletUserInfoEmailOptions
    
    enum CodingKeys: String, CodingKey {
        case email
    }
}
