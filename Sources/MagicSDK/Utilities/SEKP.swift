//
//  SEKeys.swift
//  Based on the tutorial from https://developer.apple.com/documentation/cryptokit/storing_cryptokit_keys_in_the_keychain#3369560
//  Keypairs generated from SE (Secure Enclave) can only be unwrapped by the same SE. Exporting it will be useless
//  Created by Jerry Liu on 7/5/23.
//

import Foundation

import Security
import CryptoKit

let account = "link.magic.auth.dpop".data(using: .utf8)!

// seccured enclave key pairs error
public enum SEKPError: Swift.Error {
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
    let privateKey = try SecureEnclave.P256.Signing.PrivateKey(accessControl: accessControl)

    try storeKeyToKeyChain(privateKey)

    return privateKey
}

func storeKeyToKeyChain<T: GenericPasswordConvertible>(_ key: T) throws {
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

func retrieveKeyFromKeyChain () throws -> SecureEnclave.P256.Signing.PrivateKey {
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

func deleteKeyFromKeyChain() throws {
    let query = [kSecClass: kSecClassGenericPassword,
                 kSecAttrAccount: account,
                 kSecUseDataProtectionKeychain: true] as [String: Any]

    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
        throw SEKPError.KeyStoreError("Unable to delete item: \(status.description)")
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
