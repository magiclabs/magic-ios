//
//  RecoveryMethodType.swift
//  Magic
//
//  Created by Romin Halltari on 11/22/2023.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation

public enum RecoveryMethodType: String, Codable {
    case phoneNumber = "PHONE_NUMBER"

    public var description: String {
        return rawValue.lowercased()
    }
}
