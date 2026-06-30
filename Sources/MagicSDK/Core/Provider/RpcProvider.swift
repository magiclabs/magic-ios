//
//  RpcProvider.swift
//  MagicSDK
//
//  Created by Jerry Liu on 1/20/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import MagicSDK_Web3
import WebKit
import PromiseKit

/// A custom Web3 HttpProvider that is specifically configured for use with Magic Links.
public class RpcProvider: NetworkClient, Web3Provider {

    /// Various errors that may occur while processing Web3 requests
    public enum ProviderError: Swift.Error {
        /// The provider is not configured with an authDelegate
        case encodingFailed(Swift.Error?)
        /// Decoding the JSON-RPC request failed
        case decodingFailed(json: String)
        /// Convert string failed
        case invalidJsonResponse(json: String)
        /// Missing callback
        case missingPayloadCallback(json: String)
    }

    let overlay: WebViewController
    public let urlBuilder: URLBuilder

    /// UserDefaults key for persisting the refresh token
    private let rtStorageKey = "magic_rt"

    required init(urlBuilder: URLBuilder) {
        self.overlay = WebViewController(url: urlBuilder)
        self.urlBuilder = urlBuilder
        super.init()
    }

    // MARK: - Refresh Token

    private func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: rtStorageKey)
    }

    private func persistRefreshToken(_ rt: String) {
        UserDefaults.standard.set(rt, forKey: rtStorageKey)
    }

    // MARK: - Sending Requests

    /// Sends an RPCRequest and parses the result
    /// Web3 Provider protocol conformed
    ///
    /// - Parameters:
    ///   - request: RPCRequest to send
    ///   - response: A completion handler for the response. Includes either the result or an error.
    public func send<Params, Result>(request: RPCRequest<Params>, response: @escaping Web3ResponseCompletion<Result>) {
        let msgType = OutboundMessageType.MAGIC_HANDLE_REQUEST

        // Retrieve persisted refresh token and DPoP JWT
        let rt = getRefreshToken()
        let jwt = createJwt()

        // construct message data
        let eventMessage = MagicRequestData(
            msgType: "\(msgType.rawValue)-\(urlBuilder.encodedParams)",
            payload: request,
            rt: (jwt != nil) ? rt : nil,  // only send rt when jwt is available (matches magic-js behavior)
            jwt: jwt
        )

        // encode to JSON
        firstly {
            encode(body: eventMessage)
        }.done {body throws -> Void in

            let str = try String(body)

            // enqueue and send to webview
            try self.overlay.enqueue(message: str, id: request.id) { ( responseString: String) in
                guard let jsonData = responseString.data(using: .utf8) else {
                    throw ProviderError.invalidJsonResponse(json: str)
                }

                // Decode JSON string into string
                do {
                    let rpcResponse = try self.decoder.decode(MagicResponseData<RPCResponse<Result>>.self, from: jsonData)

                    // Persist refresh token if the relayer returned a new one
                    if let newRt = rpcResponse.rt {
                        self.persistRefreshToken(newRt)
                    }

                    let result = Web3Response<Result>(rpcResponse: rpcResponse.response)
                    response(result)
                } catch {
                    throw ProviderError.decodingFailed(json: responseString)
                }
            }
        }.catch { error in
            let errResponse = Web3Response<Result>(error: ProviderError.encodingFailed(error))
            response(errResponse)
        }
    }
}

public typealias Web3ResponseCompletion<Result: Codable> = (_ resp: Web3Response<Result>) -> Void

internal extension Web3BytesInitializable {
    init(_ bytes: Web3BytesRepresentable) throws {
        let bytes = try bytes.makeBytes()
        try self.init(bytes)
    }
}
