//
//  File.swift
//  Based on the tutorial from https://developer.apple.com/documentation/cryptokit/storing_cryptokit_keys_in_the_keychain#3369560
//
//  Created by Jerry Liu on 7/5/23.
//

import Foundation

import Security
import CryptoKit

let account = "link.magic.auth.dpop".data(using: .utf8)!

// seccured enclave key pairs error
public enum SEKPError: Swift.Error {
    case generatingKPFailed(Unmanaged<CFError>?)
    case KeyStoreError(String)
}


func createP256KeyInSE () throws -> SecureEnclave.P256.Signing.PrivateKey {
    let accessControl = SecAccessControlCreateWithFlags(
        kCFAllocatorDefault,
        kSecAttrAccessibleWhenUnlocked,
        [.privateKeyUsage],
        nil
    )!
    
    // Generate a new private key in the Secure Enclave.
    let privateKey = try! SecureEnclave.P256.Signing.PrivateKey(accessControl: accessControl)
    
    try storeKey(privateKey)

    return privateKey
}

func storeKey<T: GenericPasswordConvertible>(_ key: T) throws {
    // Treat the key data as a generic password.
    let query = [kSecClass: kSecClassGenericPassword,
                 kSecAttrAccount: account,
                 kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                 kSecUseDataProtectionKeychain: true,
                 kSecValueData: key.rawRepresentation] as [String: Any]


    // Add the key data.
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
        throw SEKPError.KeyStoreError("Unable to store item: \(status.description)")
    }
}

func retrieveKey () throws -> SecureEnclave.P256.Signing.PrivateKey {
    // Seek a generic password with the given account.
    let query = [kSecClass: kSecClassGenericPassword,
                 kSecAttrAccount: account,
                 kSecUseDataProtectionKeychain: true,
                 kSecReturnData: true] as [String: Any]


    // Find and cast the result as data.
    var item: CFTypeRef?
    switch SecItemCopyMatching(query as CFDictionary, &item) {
    case errSecSuccess:
        guard let data = item as? Data else { return try createP256KeyInSE() }
        return try SecureEnclave.P256.Signing.PrivateKey(rawRepresentation: data)  // Convert back to a key.
    case errSecItemNotFound: return try createP256KeyInSE()
    case let status: throw SEKPError.KeyStoreError("Keychain read failed: \(status.description)")
    }
}


protocol GenericPasswordConvertible: CustomStringConvertible {
    /// Creates a key from a raw representation.
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes
    
    /// A raw representation of the key.
    var rawRepresentation: Data { get }
}


extension SecureEnclave.P256.Signing.PrivateKey: GenericPasswordConvertible {
    public var description: String {
        return ""
    }
    
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes {
        try self.init(dataRepresentation: data as! Data)
    }
    
    var rawRepresentation: Data {
        return dataRepresentation  // Contiguous bytes repackaged as a Data instance.
    }
}

protocol SecKeyConvertible: CustomStringConvertible {
    /// Creates a key from an X9.63 representation.
    init<Bytes>(x963Representation: Bytes) throws where Bytes: ContiguousBytes
    
    /// An X9.63 representation of the key.
    var x963Representation: Data { get }
}


