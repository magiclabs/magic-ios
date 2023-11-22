//
//  UserResponse.swift
//  Magic
//
//  Created by Romin Halltari on 11/22/2023.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//


import Foundation

public class RecoveryFactor: Codable {
    public var value: String
    public var type: RecoveryMethodType

    public init(value: String, type: RecoveryMethodType) {
        self.value = value
        self.type = type
    }

    public var description: String {
        return "value: \(value)\ntype: \(type.rawValue)\n"
    }
}
