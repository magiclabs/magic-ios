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

func createJwtWithCK()  -> String?{
    var error: Unmanaged<CFError>?
    
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
        headers["jwk"]  = [
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
        let signingInput = headersB64 + "." + claimsB64
        let signingInputData = signingInput.data(using: .utf8)!
       
        let signature = try! privateKey.signature(for: signingInputData)
        
        let signatureB64 = base64UrlEncoded(signature.rawRepresentation)
        
        let jwt = signingInput + "." + signatureB64
        
        print(jwt)
        
        return jwt

    } catch {
        // silently handled error
        print("Failed to generate JWT: \(error)")
        return nil
    }

}

