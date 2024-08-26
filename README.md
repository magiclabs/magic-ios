**We have decided to temporarily archive this repository and place it into maintenance mode. This decision allows us to focus our efforts and resources on advancing our core product line. During this period, active development and the addition of new features will be paused. We value the contributions of the community and appreciate your understanding as we prioritize our main projects. We look forward to resuming development in the future and will keep you updated on any changes.**

# MagicSDK
[![Version](https://img.shields.io/cocoapods/v/MagicSDK.svg?style=flat)](https://cocoapods.org/pods/MagicSDK)
[![License](https://img.shields.io/cocoapods/l/MagicSDK.svg?style=flat)](https://cocoapods.org/pods/MagicSDK)
[![Platform](https://img.shields.io/cocoapods/p/MagicSDK.svg?style=flat)](https://cocoapods.org/pods/MagicSDK)

## ⚠️ CocoaPods Incompatible with Xcode v14.3  ⚠️
The Magic CocoaPods SDK version (v8.0.0) is currently out of sync with the Magic SPM package version, as we await CocoaPods to fix [this compatibility issue](https://github.com/CocoaPods/CocoaPods/issues/11839). CocoaPods developers who wish to develop on the latest version of Xcode will need to integrate our SPM package.

## ⚠️ Removal of `loginWithMagicLink()`  ⚠️
As of `v9.0.0`, passcodes (ie. `loginWithSMS()`, `loginWithEmailOTP()`) are replacing Magic Links (ie. `loginWithMagicLink()`) for all of our Mobile SDKs⁠. [Learn more](https://magic.link/docs/auth/login-methods/email/email-link-update-march-2023)

## Cocoapods

### Set up the local development env
1. To start the demo app with local development SDK, download following projects
```bash
# demo app
$ git clone https://github.com/magiclabs/magic-ios-demo
# ios SDK
$ git clone https://github.com/magiclabs/magic-ios
```

2. To enable the demo use the local development SDK. Navigate to `magic-ios-demo/Podfile` and edit the following lines.
This will make pod file install local dependencies instead of the ones distributed.

```ruby 
# Distributed Library on Cocoapods
# pod 'MagicSDK', '~> 4.0'
# pod 'MagicExt-OAuth', '~> 1.0'
    
#   Local development library
pod 'MagicSDK', :path => '../magic-ios/MagicSDK.podspec'
pod 'MagicExt-OAuth', :path => '../magic-ios-ext/MagicExt-OAuth.podspec'
```

```bash
$ cd /YOUR/PATH/TO/magic-ios-demo

# Install dependencies
$ pod install
```

3. Open `/YOUR/PATH/TO/magic-ios-demo/magic-ios-demo.xcworkspace` with XCode and try it out!

---

