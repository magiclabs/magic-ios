import Foundation
import WebKit
import DeviceCheck
import CryptoKit
import Combine

public protocol MagicWebViewDelegate: AnyObject {
    func webViewCreated(_ webView: WKWebView)
    func webViewCreationFailed(_ error: Error)
}

public class MagicWebView {
    public static func checkAppAttestation(for delegate: (UIViewController & WKScriptMessageHandler & WKUIDelegate & WKNavigationDelegate & MagicWebViewDelegate)) -> AnyPublisher<WKWebView, Error> {
        // Create Webview before App Attestation check, in case of delay in attestation response from server
        let webview = createWebView(with: delegate)
        
        guard #available(iOS 14.0, *) else {
            return Fail(error: NSError(domain: "MagicWebViewError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "MagicSDK requires iOS 14 and above with App Attestation enabled"]))
                .eraseToAnyPublisher()
        }
        
        let attestationService = DCAppAttestService.shared
        
        guard attestationService.isSupported else {
            return Fail(error: NSError(domain: "MagicWebViewError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "App Attestation is unavailable for this device"]))
                .eraseToAnyPublisher()
        }
        
        return Future<String, Error> { promise in
            attestationService.generateKey { keyId, error in
                if let keyId = keyId {
                    promise(.success(keyId))
                } else {
                    promise(.failure(error ?? NSError(domain: "MagicWebViewError", code: 1003, userInfo: nil)))
                }
            }
        }
        .flatMap { keyId in
            return fetchChallengeFromServer()
                .map { challenge in (keyId, challenge) }
        }
        .flatMap { keyId, challenge in
            return Future<(Data, Data, String), Error> { promise in
                attestationService.attestKey(keyId, clientDataHash: Data(SHA256.hash(data: challenge))) { assertion, error in
                    if let assertion = assertion {
                        promise(.success((assertion, challenge, keyId)))
                    } else {
                        promise(.failure(error ?? NSError(domain: "MagicWebViewError", code: 1005, userInfo: nil)))
                    }
                }
            }
        }
        .map { assertion, challenge, keyId in
            /**
             * TODO: When Formatic Backend portion is complete, this is where we'll be sending the attestation object and a awaiting a response confirming reciept
             */
            print("THE ASSERTION IS: \(assertion)")
            print("THE CHALLENGE IS: \(challenge)")
            print("THE KEYID IS: \(keyId)")
            
            return webview
        }
        .eraseToAnyPublisher()
    }

    private static func fetchChallengeFromServer() -> Future<Data, Error> {
        return Future<Data, Error> { promise in
            /**
             * TODO: Update the URL to hit the Fortmatic Backend Endpoint directly for the challenge
             */
            guard let url = URL(string: "https://challenge-server-ngrok-app.ngrok.io/challenge") else {
                promise(.failure(NSError(domain: "MagicWebViewError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    promise(.failure(NSError(domain: "MagicWebViewError", code: httpStatus.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server returned an error"])))
                } else if let data = data {
                    promise(.success(data))
                } else {
                    promise(.failure(error ?? NSError(domain: "MagicWebViewError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network error"])))
                }
            }
            task.resume()
        }
    }

    private static func createWebView(with delegate: UIViewController & WKScriptMessageHandler & WKUIDelegate & WKNavigationDelegate) -> WKWebView {
        let webCfg: WKWebViewConfiguration = WKWebViewConfiguration()
        let userController: WKUserContentController = WKUserContentController()
        
        /**
         * Add a script message handler for receiving messages over `fortmatic` messageHandler. The controller needs to conform
         * with WKScriptMessageHandler protocol
         */
        userController.add(delegate, name: "fortmaticIOS")
        webCfg.userContentController = userController
        
        let webView = WKWebView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), // Display Full screen
            configuration: webCfg
        )
        // Transparent background
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        
        webView.uiDelegate = delegate
        
        // Conforming WKNavigationDelegate
        webView.navigationDelegate = delegate
        
        if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
            webView.isInspectable = true
        }
        
        return webView
    }
}
