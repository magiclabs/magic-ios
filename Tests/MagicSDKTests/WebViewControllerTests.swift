//
//  WebViewControllerTests.swift
//  MagicSDKTests
//

import XCTest
@testable import MagicSDK

class WebViewControllerTests: XCTestCase {

    /// Pulls the message back out of the script, the way the relayer page reads it.
    private func decodedMessage(from script: String) throws -> String {
        let prefix = "window.dispatchEvent(new MessageEvent('message', "
        let suffix = "));"
        XCTAssertTrue(script.hasPrefix(prefix) && script.hasSuffix(suffix))
        let json = String(script.dropFirst(prefix.count).dropLast(suffix.count))
        let object = try JSONDecoder().decode([String: String].self, from: Data(json.utf8))
        return try XCTUnwrap(object["data"])
    }

    func testDispatchScriptKeepsPercentSignsUnchanged() throws {
        let messages = [
            "hello",
            "https://example.com/?q=a%2Fb&x=1",
            "growth 100%",
            "price %d units",
            "%@ %s %n %%",
        ]
        for message in messages {
            let script = try WebViewController.dispatchScript(for: message)
            XCTAssertEqual(try decodedMessage(from: script), message)
        }
    }
}
