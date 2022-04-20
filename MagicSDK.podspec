#
# Podspec for Cocoapod
#
Pod::Spec.new do |s|
  s.name             = 'MagicSDK'
  s.version          = '3.1.0'
  s.summary          = 'Magic IOS SDK'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/magiclabs/magic-ios'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jerry Liu' => 'jerry@magic.link' }
  s.source           = { :git => 'https://github.com/magiclabs/magic-ios.git', :tag => s.version.to_s }
  s.swift_version = '5.0'
  s.ios.deployment_target = '10.0'
#   s.osx.deployment_target  = '10.12'

  s.source_files = 'Sources/MagicSDK/**/*'

  s.dependency 'MagicSDK-Web3', '~> 1.0'
  s.dependency 'MagicSDK-Web3/ContractABI', '~> 1.0'
  s.dependency 'MagicSDK-Web3/PromiseKit', '~> 1.0'

  s.dependency 'PromiseKit/CorePromise', '~> 6.15'

  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
