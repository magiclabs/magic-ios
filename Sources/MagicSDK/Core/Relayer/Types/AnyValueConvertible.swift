//
//  AnyValueConvertible.swift
//  MagicSDK
//
//  Created by Jerry Liu on 07/13/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation

/**
 * Objects which can be converted to `AnyValue` can implement this.
 */
public protocol AnyValueRepresentable: Encodable {

    /**
     * Converts `self` to `AnyValue`.
     *
     * - returns: The generated `AnyValue`.
     */
    func anyValue() -> AnyValue
}

/**
 * Objects which can be initialized with `AnyValue`'s can implement this.
 */
public protocol AnyValueInitializable: Decodable {

    /**
     * Initializes `self` with the given `AnyValue` if possible. Throws otherwise.
     *
     * - parameter AnyValue: The `AnyValue` to be converted to `self`.
     */
    init(anyValue: AnyValue) throws
}

/**
 * Objects which are both representable and initializable by and with `AnyValue`'s.
 */
public typealias AnyValueConvertible = AnyValueRepresentable & AnyValueInitializable

extension AnyValueInitializable {

    public init(anyValue: AnyValueRepresentable) throws {
        let e = anyValue.anyValue()
        try self.init(anyValue: e)
    }
}

// MARK: - Default Codable

extension AnyValueRepresentable {

    public func encode(to encoder: Encoder) throws {
        try anyValue().encode(to: encoder)
    }
}

extension AnyValueInitializable {

    public init(from decoder: Decoder) throws {
        try self.init(anyValue: AnyValue(from: decoder))
    }
}

// MARK: - Errors

public enum AnyValueRepresentableError: Swift.Error {

    case notRepresentable
}

public enum AnyValueInitializableError: Swift.Error {

    case notInitializable
}
