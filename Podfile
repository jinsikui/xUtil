# Uncomment the next line to define a global platform for your project

platform :ios, '10.0'

use_frameworks!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

def common
  pod 'KVOController'
  pod 'PromisesObjC'
  pod 'YYKit'
  pod 'SocketRocket'
  pod 'SDWebImage'
  pod 'AFNetworking', '~>4.0.0'
  pod 'FMDB'
  pod 'Masonry'
  pod 'xUI', :git => "https://github.com/jinsikui/xUI.git", :branch => 'master'
  pod 'ReactiveObjC'
  pod 'ReactiveCocoa'
  pod 'ReactiveObjCBridge'
end

target 'xUtil' do
  common
end

target 'xUtilTests' do
  common
end
