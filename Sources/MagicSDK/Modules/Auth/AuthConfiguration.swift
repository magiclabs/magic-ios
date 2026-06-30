//
//  Configuration.swift
//  MagicSDK
//
//  Created by Jerry Liu on 5/14/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation


public struct LoginWithSmsConfiguration: BaseConfiguration {

    public var phoneNumber: String
    var showUI: Bool
    var lifespan: Int?

    public init(phoneNumber: String, showUI: Bool = true, lifespan: Int? = nil) {
        self.phoneNumber = phoneNumber
        self.showUI = showUI
        self.lifespan = lifespan
    }
}

public struct LoginWithEmailOTPConfiguration: BaseConfiguration {

    public var email: String
    var showUI: Bool
    var deviceCheckUI: Bool
    var overrides: LoginWithEmailOTPOverrides?
    var lifespan: Int?

    public init(email: String, showUI: Bool = true, overrides: LoginWithEmailOTPOverrides? = nil, lifespan: Int? = nil) {
        self.email = email
        self.showUI = showUI
        self.deviceCheckUI = showUI
        self.overrides = overrides
        self.lifespan = lifespan
    }
}

public struct LoginWithEmailOTPOverrides: BaseConfiguration {
    var variation: String?
    var appName: String?
    var assetUrl: String?

    public init(variation: String? = nil, appName: String? = nil, assetUrl: String? = nil) {
        self.variation = variation
        self.appName = appName
        self.assetUrl = assetUrl
    }
}
