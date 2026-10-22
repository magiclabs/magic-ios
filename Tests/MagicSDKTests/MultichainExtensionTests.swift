import XCTest
import MagicSDK_Web3
@testable import MagicSDK

/// Stands in for an extension package's configuration, such as `SolanaConfiguration`.
private struct TestConfiguration: ExtensionConfiguration {
    let name: String
    let rpcUrl: String
    var chainType: String { name.uppercased() }
    var options: [String: String]?

    enum CodingKeys: String, CodingKey { case rpcUrl, chainType, options }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(rpcUrl, forKey: .rpcUrl)
        try container.encode(chainType, forKey: .chainType)
        try container.encodeIfPresent(options, forKey: .options)
    }
}

final class MultichainExtensionTests: XCTestCase {

    private func json(_ value: Encodable) throws -> [String: Any] {
        struct Box: Encodable {
            let value: Encodable
            func encode(to encoder: Encoder) throws { try value.encode(to: encoder) }
        }
        let data = try JSONEncoder().encode(Box(value: value))
        return try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func urlParams(_ urlBuilder: URLBuilder) throws -> [String: Any] {
        let decoded = atob(encodedString: urlBuilder.encodedParams)
        return try XCTUnwrap(JSONSerialization.jsonObject(with: Data(decoded.utf8)) as? [String: Any])
    }

    // MARK: - Typed array

    func testTypedArrayEncodesInMgboxFormat() throws {
        let encoded = try json(TypedArray(Data([99, 53, 247])))
        XCTAssertEqual(encoded["constructor"] as? String, "Uint8Array")
        XCTAssertEqual(encoded["data"] as? String, "99,53,247")
        XCTAssertEqual(encoded["flag"] as? String, "MAGIC_PAYLOAD_FLAG_TYPED_ARRAY")
    }

    func testTypedArrayDecodesBufferAndEmpty() throws {
        let buffer = #"{"constructor":"Buffer","data":"1,2,255","flag":"MAGIC_PAYLOAD_FLAG_TYPED_ARRAY"}"#
        XCTAssertEqual(try JSONDecoder().decode(TypedArray.self, from: Data(buffer.utf8)).data, Data([1, 2, 255]))

        let empty = #"{"constructor":"Uint8Array","data":"","flag":"MAGIC_PAYLOAD_FLAG_TYPED_ARRAY"}"#
        XCTAssertEqual(try JSONDecoder().decode(TypedArray.self, from: Data(empty.utf8)).data, Data())
    }

    func testTypedArrayRejectsBadInput() {
        let noFlag = #"{"constructor":"Uint8Array","data":"1,2","flag":"OTHER"}"#
        XCTAssertThrowsError(try JSONDecoder().decode(TypedArray.self, from: Data(noFlag.utf8)))

        let badByte = #"{"constructor":"Uint8Array","data":"1,256","flag":"MAGIC_PAYLOAD_FLAG_TYPED_ARRAY"}"#
        XCTAssertThrowsError(try JSONDecoder().decode(TypedArray.self, from: Data(badByte.utf8)))
    }

    // MARK: - URL params

    func testUrlParamsOmitExtWithoutExtensions() throws {
        let params = try urlParams(URLBuilder(apiKey: "pk_test", network: .mainnet, locale: "en_US"))
        XCTAssertNil(params["ext"])
        XCTAssertEqual(params["ETH_NETWORK"] as? String, "mainnet")
    }

    func testUrlParamsEncodeExtLikeMagicJs() throws {
        let urlBuilder = URLBuilder(
            apiKey: "pk_test",
            network: .mainnet,
            extensions: [
                TestConfiguration(name: "solana", rpcUrl: "https://api.devnet.solana.com"),
                TestConfiguration(name: "bitcoin", rpcUrl: "https://btc.example.com", options: ["network": "testnet"]),
            ],
            locale: "en_US"
        )
        let ext = try XCTUnwrap(try urlParams(urlBuilder)["ext"] as? [String: Any])

        let solana = try XCTUnwrap(ext["solana"] as? [String: Any])
        XCTAssertEqual(solana.count, 2)
        XCTAssertEqual(solana["rpcUrl"] as? String, "https://api.devnet.solana.com")
        XCTAssertEqual(solana["chainType"] as? String, "SOLANA")

        let bitcoin = try XCTUnwrap(ext["bitcoin"] as? [String: Any])
        XCTAssertEqual(bitcoin.count, 3)
        XCTAssertEqual(bitcoin["rpcUrl"] as? String, "https://btc.example.com")
        XCTAssertEqual(bitcoin["chainType"] as? String, "BITCOIN")
        XCTAssertEqual(bitcoin["options"] as? [String: String], ["network": "testnet"])
    }

    func testLaterExtensionWithSameNameWins() throws {
        let urlBuilder = URLBuilder(
            apiKey: "pk_test",
            extensions: [TestConfiguration(name: "solana", rpcUrl: "https://a"), TestConfiguration(name: "solana", rpcUrl: "https://b")],
            locale: "en_US"
        )
        let ext = try XCTUnwrap(try urlParams(urlBuilder)["ext"] as? [String: Any])
        XCTAssertEqual((ext["solana"] as? [String: Any])?["rpcUrl"] as? String, "https://b")
    }

    // MARK: - Request shape

    func testMultichainRequestShape() throws {
        let request = RPCRequest<[MultichainExtension.ChainParams]>(
            method: MultichainMethod.magic_get_multichain_public_address.rawValue,
            params: [MultichainExtension.ChainParams(chain: "SOLANA")]
        )
        let encoded = try json(request)
        XCTAssertEqual(encoded["method"] as? String, "magic_get_multichain_public_address")
        XCTAssertEqual(encoded["params"] as? [[String: String]], [["chain": "SOLANA"]])
    }

    func testMethodNamesMatchMagicJs() {
        XCTAssertEqual(MultichainMethod.magic_get_multichain_public_address.rawValue, "magic_get_multichain_public_address")
        XCTAssertEqual(MultichainMethod.magic_reveal_key.rawValue, "magic_reveal_key")
    }
}
