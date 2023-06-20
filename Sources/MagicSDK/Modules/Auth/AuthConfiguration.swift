//
//  Configuration.swift
//  MagicSDK
//
//  Created by Jerry Liu on 5/14/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation


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
