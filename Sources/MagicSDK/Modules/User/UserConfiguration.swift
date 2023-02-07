//
//  UserConfiguration.swift
//  Magic
//
//  Created by Jerry Liu on 3/4/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation
import MagicSDK_Web3

/// Get Id Token configuration
public class GetIdTokenConfiguration: BaseConfiguration {
    
    var lifespan: Int
    
    public init(lifespan: Int = 900) {
        self.lifespan = lifespan
    }
}


public class GenerateIdTokenConfiguration: BaseConfiguration {
    var attachment: String
    var lifespan: Int
    
    public init(lifespan: Int = 900, attachment: String = "none") {
        self.lifespan = lifespan
        self.attachment = attachment
    }
}

public class UpdateEmailConfiguration: BaseConfiguration {
    var email: String
    var showUI: Bool
    
    public init(email: String, showUI: Bool = true){
        self.email = email
        self.showUI = showUI
    }
}
