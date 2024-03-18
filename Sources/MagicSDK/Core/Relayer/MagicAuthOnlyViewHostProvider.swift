//
//  MagicAuthOnlyViewHostProvider.swift
//
//
//  Created by Arian Flores - Magic on 3/13/24.
//

import Foundation
import UIKit

public protocol MagicAuthOnlyViewHostProviding {
    func provide() throws -> UIViewController
}

struct MagicAuthOnlyViewHostProvider: MagicAuthOnlyViewHostProviding {
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

private extension MagicAuthOnlyViewHostProvider {
    func keyWindow() throws -> UIWindow {
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow}).first else {
            throw WebViewController.AuthRelayerError.topMostWindowNotFound
        }

        return window
    }
}
