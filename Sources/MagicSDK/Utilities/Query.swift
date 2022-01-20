//
//  Query.swift
//  Magic
//
//  Created by Jerry Liu on 2/5/20.
//

import Foundation

enum QueryConstructError: Error {
    case generationFailed(code: String)
}

public func btoa(jsonString: String) -> String {
    if let utf8str = jsonString.data(using: String.Encoding.utf8) {
        let base64 = utf8str.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        return base64
    }
    return ""
}

func atob(encodedString: String) -> String {
    let decodedData = Data(base64Encoded: encodedString)!
    return String(data: decodedData, encoding: .utf8)!
}
