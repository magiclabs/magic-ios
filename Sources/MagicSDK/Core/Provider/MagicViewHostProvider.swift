//
//  MagicViewHostProvider.swift
//  
//
//  Created by Tristan Warner-Smith on 27/02/2024.
//

import UIKit

public protocol MagicViewHostProviding {
    func provide() throws -> UIViewController
}

struct MagicViewHostProvider: MagicViewHostProviding {
    public init() {}

    func provide() throws -> UIViewController {
        let window = try keyWindow()
        // Find topmost view controller from the hierarchy and move webview to it
        if var topController = window.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            throw WebViewController.AuthRelayerError.topMostWindowNotFound
        }
    }
}

private extension MagicViewHostProvider {
    func keyWindow() throws -> UIWindow {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow}).first else {
            throw WebViewController.AuthRelayerError.topMostWindowNotFound
        }

        return window
    }
}
