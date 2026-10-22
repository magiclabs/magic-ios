//
//  ExtensionConfiguration.swift
//  MagicSDK
//

import Foundation

/// Configuration for an official Magic extension, such as Solana or Bitcoin.
///
/// Pass these to `Magic(apiKey:extensions:)`. Each one is sent to the relayer
/// under `ext.<name>` in the URL params, the same as extensions in magic-js.
public protocol ExtensionConfiguration: Encodable {
    /// The extension name, e.g. `solana`. Matches the `name` field in magic-js.
    var name: String { get }
}

/// Encodes a list of extension configs as `{ "<name>": <config>, ... }`.
/// A later config with the same name replaces an earlier one, as in magic-js.
struct ExtensionConfigurations: Encodable {

    let configurations: [ExtensionConfiguration]

    var isEmpty: Bool { configurations.isEmpty }

    struct NameKey: CodingKey {
        let stringValue: String
        var intValue: Int? { nil }
        init(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    func encode(to encoder: Encoder) throws {
        var byName: [String: ExtensionConfiguration] = [:]
        configurations.forEach { byName[$0.name] = $0 }

        var container = encoder.container(keyedBy: NameKey.self)
        for (name, configuration) in byName.sorted(by: { $0.key < $1.key }) {
            try configuration.encode(to: container.superEncoder(forKey: NameKey(stringValue: name)))
        }
    }
}
