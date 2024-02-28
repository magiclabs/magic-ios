//
//  WebViewController.swift
//  Magic
//
//  Created by Jerry Liu on 2/1/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import WebKit
import UIKit
import os

/// An instance of the Fortmatc Phantom WebView
class WebViewController: UIViewController, WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate, UIScrollViewDelegate {
    @available(iOS 14.0, *)
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: WebViewController.self)
    )
    
    /// Various errors that may occur while processing Web3 requests
    public enum AuthRelayerError: Error {

        ///Message encode fail
        case messageEncodeFailed(message: String)

        case webviewAttachedFailed
        case topMostWindowNotFound
    }

    /// This name is reserved for internal use
    let messageName = "fortmaticIOS"

    var webView: WKWebView!

    /// X source url
    var urlBuilder: URLBuilder!

    /// Overlay Ready
    var overlayReady = false
    var webViewFinishLoading = false

    /// Queue and callbackss
    var queue: [String] = []
    var messageHandlers: Dictionary<Int, MessageHandler> = [:]

    typealias MessageHandler = (String) throws ->  Void

    // MARK: - init
    init(url: URLBuilder) {
        self.urlBuilder = url
        super.init(nibName: nil, bundle: nil)
    }

    // Required provided by subclass of 'UIViewController'
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Message Queue
    func enqueue(message: String, id: Int, closure: @escaping MessageHandler) throws -> Void {
        queue.append(message)
        messageHandlers[id] = closure
        try self.dequeue()
    }

    private func dequeue() throws -> Void {

        // Check if UI is appeneded properly to current screen before dequeue
        guard let window = UIApplication.shared.keyWindow else { return try attachWebView() }

        if self.view.isDescendant(of: window) {

            if !queue.isEmpty && overlayReady && webViewFinishLoading {
                let message = queue.removeFirst()
                try self.postMessage(message: message)

                // Recursive calls till queue is Empty
                try self.dequeue()
            }
        } else {
            try attachWebView()
        }
    }


    // MARK: - Receive Messages

    /// handler for received messages
    /// conforming WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        do {
            if message.name == messageName {
                guard let payloadStr = message.body as? String else { return }

                if payloadStr.contains(InboundMessageType.MAGIC_OVERLAY_READY.rawValue) {
                    overlayReady = true
                    try? self.dequeue()
                } else if payloadStr.contains(InboundMessageType.MAGIC_SHOW_OVERLAY.rawValue) {
                    try bringWebViewToFront()
                } else if payloadStr.contains(InboundMessageType.MAGIC_HIDE_OVERLAY.rawValue) {
                    try sendSubviewToBack()
                } else if payloadStr.contains(InboundMessageType.MAGIC_HANDLE_EVENT.rawValue) {
                    try handleEvent(payloadStr: payloadStr)
                } else if payloadStr.contains(InboundMessageType.MAGIC_HANDLE_RESPONSE.rawValue) {
                    try handleResponse(payloadStr: payloadStr)
                } else if payloadStr.contains(InboundMessageType.MAGIC_SEND_PRODUCT_ANNOUNCEMENT.rawValue) {
                    try makeProductAnnouncement(payloadStr: payloadStr)
                }
            }
            try self.dequeue()
        }catch let error {
            print("Magic internal error: \(error.localizedDescription)")
        }
    }

    private func handleEvent(payloadStr: String) throws -> Void {

        // Decode here to get the event name
        let eventData = payloadStr.data(using: .utf8)!
        let eventResponse = try JSONDecoder().decode(MagicResponseData<MagicEventResponse<[AnyValue]>>.self, from: eventData)

        // post event to the obeserver
        let event = eventResponse.response
        if let eventName = event.result.event {
            NotificationCenter.default.post(name: Notification.Name.init(eventName), object: nil, userInfo: ["event": event.result])
        }
    }

    private func handleResponse(payloadStr: String) throws -> Void {

        /// Take id out from JSON string
        if let range = payloadStr.range(of: "(?<=\"id\":)(.*?)(?=,)", options: .regularExpression) {

            guard let id = Int(payloadStr[range]) else {

                /// throws when response has no matching id
                throw RpcProvider.ProviderError.invalidJsonResponse(json: payloadStr)
            }

            // Call callback stored
            if let callback = self.messageHandlers[id] {
                try callback(payloadStr)
                self.messageHandlers[id] = nil
            } else {

                /// throws when response couldn't match a callback
                throw RpcProvider.ProviderError.missingPayloadCallback(json: payloadStr)
            }
        } else {
            throw RpcProvider.ProviderError.invalidJsonResponse(json: payloadStr)
        }
    }
    
    private func makeProductAnnouncement(payloadStr: String) throws {
        // Decoding the JSON string into the Payload struct
        guard let data = payloadStr.data(using: .utf8) else {
            throw NSError(domain: "Invalid payload string", code: 1001, userInfo: nil)
        }
        
        // Define a typealias for the expected payload type
        typealias PayloadType = MagicResponseData<MagicEventResponse<ProductAnnouncement>>

        let payload = try JSONDecoder().decode(PayloadType.self, from: data)
        if let announcement = payload.response.result.product_announcement {
            if #available(iOS 14.0, *) {
                os_log("%{public}@", log: .default, type: .info, announcement)
            } else {
                print(announcement)
            }
        } else {
            // Handle missing announcement
            print("No product announcement found")
        }
    }



    // MARK: - Post Messages


    /// post Message to HTML via evaluateJavaScript
    ///
    internal func postMessage(message: String) throws -> Void {

        let data: [String: String] = ["data": message]

        guard let json = try? JSONEncoder().encode(data),
              let jsonString = String(data: json, encoding: .utf8) else {
            throw AuthRelayerError.messageEncodeFailed(message: message)
        }

        let execString = String(format: "window.dispatchEvent(new MessageEvent('message', \(jsonString)));")
        webView.evaluateJavaScript(execString)
    }




    // MARK: - view loading
    /// loadView will be triggered when addsubview is called. It will create a webview to post messages to auth relayer
    override func loadView() {

        // Display Full screen
        let cgRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let webView: WKWebView = {

            let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
            let userController:WKUserContentController = WKUserContentController()

            // Add a script message handler for receiving messages over `fortmatic` messageHandler. The controller needs to conform
            // with WKScriptMessageHandler protocol
            userController.add(self, name: messageName)
            webCfg.userContentController = userController;

            let webView = WKWebView(frame: cgRect, configuration: webCfg)

            // Transparent background
            webView.backgroundColor = UIColor.clear
            webView.scrollView.backgroundColor = UIColor.clear
            webView.isOpaque = false

            webView.uiDelegate = self

            if #available(macOS 13.3, iOS 16.4, tvOS 16.4, *) {
                webView.isInspectable = true
            }

            // conforming WKNavigationDelegate
            webView.navigationDelegate = self

            return webView
        }()
        self.webView = webView
        view = webView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let myURL = URL(string: urlBuilder.url)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.scrollView.delegate = self // disable zoom
    }

    /// Check did finished navigating, conforming WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webViewFinishLoading = true
        do {
            try self.dequeue()
        } catch {}
    }

    /**
     * The WKWebView will call this method when a web application calls window.open() in JavaScript.
     */
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Make sure the URL is set.
        guard let url = navigationAction.request.url,
              let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let openInDeviceBrowser = urlComponents.queryItems?.first(where: { $0.name == "open_in_device_browser" })?.value?.lowercased()
        else {
            return nil
        }

        if UIApplication.shared.canOpenURL(url) && openInDeviceBrowser == "true" {
            // Open the link in the external browser.
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }

        return nil
    }

    // handle external link clicked events
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Check for links.
            if navigationAction.navigationType == .linkActivated {
                // Make sure the URL is set.
                guard let url = navigationAction.request.url else {
                    decisionHandler(.allow)
                    return
                }

                // Check for the scheme component.
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                if components?.scheme == "http" || components?.scheme == "https" {
                    // Open the link in the external browser.
                    UIApplication.shared.open(url)
                    // Cancel the decisionHandler because we managed the navigationAction.
                    decisionHandler(.cancel)
                } else {
                    decisionHandler(.allow)
                }
            } else {
                decisionHandler(.allow)
            }
        }



    // MARK: - View

    /// Disable zooming for webview
    func viewForZooming(in: UIScrollView) -> UIView? {
        return nil;
    }

    private func sendSubviewToBack() throws -> Void {

        let keyWindow = try getKeyWindow()
        keyWindow.sendSubviewToBack(self.view)
    }

    private func bringWebViewToFront() throws -> Void {

        let keyWindow = try getKeyWindow()
        keyWindow.bringSubviewToFront(self.view)
    }

    private func getKeyWindow() throws -> UIWindow {

        guard let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
            throw AuthRelayerError.topMostWindowNotFound
        }

        return keyWindow
    }

    private func attachWebView() throws -> Void {

        let keyWindow = try getKeyWindow()

        keyWindow.addSubview(self.view)
        keyWindow.sendSubviewToBack(self.view)

        // find topmost view controller from the hierarchy and move webview to it
        if var topController = keyWindow.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            self.didMove(toParent: topController)

        } else {
            throw AuthRelayerError.webviewAttachedFailed
        }
    }
}


