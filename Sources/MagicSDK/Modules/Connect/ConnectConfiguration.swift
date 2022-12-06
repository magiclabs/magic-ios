//
//  ConnectConfiguration.swift
//
//
//  Created by Jerry Liu on 9/16/22.
//

import Foundation

public struct RequestUserInfoConfiguration: BaseConfiguration {

    ///
    public var isResponseRequired = false

    public init(isResponseRequired: Bool = false) {
        self.isResponseRequired = isResponseRequired
    }
}
