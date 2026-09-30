import XCTest
import MagicSDK_Web3
@testable import MagicSDK

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
                SolanaConfiguration(rpcUrl: "https://api.devnet.solana.com"),
                BitcoinConfiguration(rpcUrl: "https://btc.example.com", network: "testnet"),
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
            extensions: [SolanaConfiguration(rpcUrl: "https://a"), SolanaConfiguration(rpcUrl: "https://b")],
            locale: "en_US"
        )
        let ext = try XCTUnwrap(try urlParams(urlBuilder)["ext"] as? [String: Any])
        XCTAssertEqual((ext["solana"] as? [String: Any])?["rpcUrl"] as? String, "https://b")
    }

    // MARK: - Solana params

    func testSolanaLegacyTransactionParams() throws {
        let params = try json(SolanaTransactionParams(
            type: .legacy,
            serialized: Data([1, 2, 3]),
            serializeConfig: SolanaSerializeConfig(requireAllSignatures: false)
        ))
        XCTAssertEqual(params["type"] as? String, "legacy")
        XCTAssertEqual((params["serialized"] as? [String: Any])?["data"] as? String, "1,2,3")
        XCTAssertEqual(params["serializeConfig"] as? [String: Bool], ["requireAllSignatures": false])
    }

    func testSolanaVersionedTransactionParams() throws {
        let params = try json(SolanaTransactionParams(type: .v0, serialized: Data([4]), serializeConfig: nil))
        XCTAssertEqual(params["type"] as? Int, 0)
        XCTAssertNil(params["serializeConfig"])
    }

    func testSolanaSignMessageParams() throws {
        XCTAssertEqual(try json(SolanaSignMessageParams(message: .string("hello")))["message"] as? String, "hello")

        let bytes = try json(SolanaSignMessageParams(message: .bytes(TypedArray(Data([7, 8])))))
        XCTAssertEqual((bytes["message"] as? [String: Any])?["data"] as? String, "7,8")
    }

    func testSolanaSignedTransactionDecodesMgboxResponse() throws {
        let response = #"""
        {"rawTransaction":{"constructor":"Buffer","data":"9,8,7","flag":"MAGIC_PAYLOAD_FLAG_TYPED_ARRAY"},
         "signature":[{"signature":null,"publicKey":"11111111111111111111111111111111"}]}
        """#
        let signed = try JSONDecoder().decode(SolanaSignedTransaction.self, from: Data(response.utf8))
        XCTAssertEqual(signed.rawTransaction, Data([9, 8, 7]))
    }

    // MARK: - Bitcoin params

    func testBitcoinTransactionParams() throws {
        let params = try json(BitcoinTransactionParams(
            inputs: [BitcoinTransactionInput(txid: "abc", txNum: 1, value: 0.0001)],
            outputs: [BitcoinTransactionOutput(address: "tb1q", value: 0.00005)]
        ))
        let input = try XCTUnwrap((params["inputs"] as? [[String: Any]])?.first)
        XCTAssertEqual(input["txid"] as? String, "abc")
        XCTAssertEqual(input["tx_num"] as? Int, 1)
        XCTAssertEqual(input["value"] as? Double, 0.0001)
        XCTAssertNil(input["address"])
        XCTAssertNil(input["txNum"])

        let output = try XCTUnwrap((params["outputs"] as? [[String: Any]])?.first)
        XCTAssertEqual(output["address"] as? String, "tb1q")
        XCTAssertEqual(output["value"] as? Double, 0.00005)
    }

    // MARK: - Request shape

    func testMultichainRequestShape() throws {
        let request = RPCRequest<[MultichainExtension.ChainParams]>(
            method: MultichainMethod.magic_get_multichain_public_address.rawValue,
            params: [MultichainExtension.ChainParams(chain: SolanaExtension.chainType)]
        )
        let encoded = try json(request)
        XCTAssertEqual(encoded["method"] as? String, "magic_get_multichain_public_address")
        XCTAssertEqual(encoded["params"] as? [[String: String]], [["chain": "SOLANA"]])
    }

    func testMethodNamesMatchMagicJs() {
        XCTAssertEqual(SolanaMethod.sol_signTransaction.rawValue, "sol_signTransaction")
        XCTAssertEqual(SolanaMethod.sol_signMessage.rawValue, "sol_signMessage")
        XCTAssertEqual(SolanaMethod.sol_partialSignTransaction.rawValue, "sol_partialSignTransaction")
        XCTAssertEqual(BitcoinMethod.btc_signTransaction.rawValue, "btc_signTransaction")
        XCTAssertEqual(MultichainMethod.magic_reveal_key.rawValue, "magic_reveal_key")
    }
}
