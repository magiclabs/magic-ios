//
//  Configuration.swift
//  MagicSDK
//
//  Created by Jerry Liu on 5/14/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation

/// LoginWithMagicLink configuration
public struct LoginWithMagicLinkConfiguration: BaseConfiguration {
    
    /// Shows UI if sets to true
    public var showUI: Bool
    public var email: String
    
    public init(showUI: Bool = true, email: String) {
        self.showUI = showUI
        self.email = email
    }
}

public struct LoginWithSmsConfiguration: BaseConfiguration {
    
    ///
    public var phoneNumber: String
    var showUI = true
    
    public init(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
}

public struct LoginWithEmailOTPConfiguration: BaseConfiguration {
    
    public var email: String
    
    public init(email: String) {
        self.email = email
    }
}
