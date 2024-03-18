//
//  File.swift
//
//
//  Created by Wentao Liu on 7/11/23.
//

import Foundation
import CryptoKit


func base64UrlEncoded(_ data: Data) -> String {
    var b64 = data.base64EncodedString()
    b64 = b64.replacingOccurrences(of: "+", with: "-")
    b64 = b64.replacingOccurrences(of: "/", with: "_")
    b64 = b64.replacingOccurrences(of: "=", with: "")
    return b64
}


func createJwt() -> String? {
    var attempts = 0
    
    while attempts < 3 { // Attempt the retry flow at a maximum of 3 times before giving up
        do {
            let privateKey = try retrieveKeyFromKeyChain()
            
            // Get the public key.
            let publicKey = privateKey.publicKey
            
            // Get the raw representation of the public key.
            let rawPublicKey = publicKey.rawRepresentation
            
            // Extract the x and y coordinates.
            let xCoordinateData = rawPublicKey[1..<33]
            let yCoordinateData = rawPublicKey[33..<65]
            
            // If you need base64-encoded strings for JWK:
            let xCoordinateBase64 = base64UrlEncoded(xCoordinateData)
            let yCoordinateBase64 = base64UrlEncoded(yCoordinateData)
            
            // Convert the public key to JWK format.
            // construct headers
            var headers: [String: Any] = ["typ": "dpop+jwt", "alg": "ES256"]
            headers["jwk"] = [
                "kty": "EC",
                "crv": "P-256",
                "x": xCoordinateBase64,
                "y": yCoordinateBase64
            ] as [String : Any]

            let headersData = try JSONSerialization.data(withJSONObject: headers)
            let headersB64 = base64UrlEncoded(headersData)
            
            // construct claims
            let iat = Int(Date().timeIntervalSince1970)
            let jti = UUID().uuidString.lowercased()

            let claims: [String: Any] = ["iat": iat, "jti": jti]
            let claimsData = try JSONSerialization.data(withJSONObject: claims)
            let claimsB64 = base64UrlEncoded(claimsData)
            
            /// sign
            let signingInput =  headersB64 + "." + claimsB64
            
            guard let signingInputData = signingInput.data(using: .utf8),
                  let signature = try? privateKey.signature(for: signingInputData) else {
                // This can happen when the [secure enclave biometrics](https://developer.apple.com/forums/thread/682162?answerId=726099022#726099022) 
                // have changed such as when an app is auto-installed on a new device, ergo delete previously created key and try again
                try deleteKeyFromKeyChain()
                attempts += 1
                continue
            }

            let signatureB64 = base64UrlEncoded(signature.rawRepresentation)
            let jwt = signingInput + "." + signatureB64
            
            return jwt

        } catch {
            // Handle error (log, throw, or break as necessary)
            print("An error occurred: \(error)")
            break
        }
    }
    return nil // Return nil if unable to generate JWT after 3x retries
}

