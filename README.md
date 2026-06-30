# MagicSDK

## ⚠️ Removal of `loginWithMagicLink()`  ⚠️
As of `v9.0.0`, passcodes (ie. `loginWithSMS()`, `loginWithEmailOTP()`) are replacing Magic Links (ie. `loginWithMagicLink()`) for all of our Mobile SDKs⁠. [Learn more](https://magic.link/docs/auth/login-methods/email/email-link-update-march-2023)

## Swift Package Manager

Add the package in Xcode via **File → Add Package Dependencies** and enter:

```
https://github.com/magiclabs/magic-ios.git
```

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/magiclabs/magic-ios.git", from: "10.2.0")
]
```

## Example

A SwiftUI demo app is included in `Example/MagicDemo`. Add the MagicSDK package to your app (Swift Package Manager) and copy the example source files into your target. Set your publishable API key in `MagicDemoApp.swift`.

---
