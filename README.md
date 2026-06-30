**We have decided to temporarily archive this repository and place it into maintenance mode. This decision allows us to focus our efforts and resources on advancing our core product line. During this period, active development and the addition of new features will be paused. We value the contributions of the community and appreciate your understanding as we prioritize our main projects. We look forward to resuming development in the future and will keep you updated on any changes.**

# MagicSDK
[![Version](https://img.shields.io/cocoapods/v/MagicSDK.svg?style=flat)](https://cocoapods.org/pods/MagicSDK)
[![License](https://img.shields.io/cocoapods/l/MagicSDK.svg?style=flat)](https://cocoapods.org/pods/MagicSDK)
[![Platform](https://img.shields.io/cocoapods/p/MagicSDK.svg?style=flat)](https://cocoapods.org/pods/MagicSDK)

## ⚠️ CocoaPods Incompatible with Xcode v14.3  ⚠️
The Magic CocoaPods SDK version (v8.0.0) is currently out of sync with the Magic SPM package version, as we await CocoaPods to fix [this compatibility issue](https://github.com/CocoaPods/CocoaPods/issues/11839). CocoaPods developers who wish to develop on the latest version of Xcode will need to integrate our SPM package.

## ⚠️ Removal of `loginWithMagicLink()`  ⚠️
As of `v9.0.0`, passcodes (ie. `loginWithSMS()`, `loginWithEmailOTP()`) are replacing Magic Links (ie. `loginWithMagicLink()`) for all of our Mobile SDKs⁠. [Learn more](https://magic.link/docs/auth/login-methods/email/email-link-update-march-2023)

## Example

A SwiftUI demo app is included in `Example/MagicDemo`. Add the MagicSDK package to your app (Swift Package Manager) and copy the example source files into your target. Set your publishable API key in `MagicDemoApp.swift`.

---

