# MagicSDK

The Magic SDK for iOS. It adds passwordless login and an embedded wallet to your app. See the [iOS SDK reference](https://docs.magic.link/embedded-wallets/sdk/client-side/ios) for the full guide.

Requires iOS 13 or later.

## Swift Package Manager

Add the package in Xcode via **File → Add Package Dependencies** and enter:

```
https://github.com/magiclabs/magic-ios.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/magiclabs/magic-ios.git", from: "10.3.0")
]
```

## Quick start

```swift
import MagicSDK

Magic.shared = Magic(apiKey: "YOUR_PUBLISHABLE_API_KEY")
```

## Solana and Bitcoin

Solana and Bitcoin live in the [magic-ios-ext](https://github.com/magiclabs/magic-ios-ext) package, as the `MagicExt-Solana` and `MagicExt-Bitcoin` products. This SDK has the hooks they use: pass their configurations to `Magic(apiKey:extensions:)`, and read the result from `Magic.shared.solana` or `Magic.shared.bitcoin`. See that repo's README for how to sign messages and transactions.

## Example

The [magic-ios-demo](https://github.com/magiclabs/magic-ios-demo) app shows login, EVM, Solana (legacy and v0 transactions) and Bitcoin. Open `magic-ios-spm-demo.xcodeproj`, not the workspace, and set your publishable API key in `AppDelegate.swift`.

---
