#
#  Be sure to run `pod spec lint xUtil.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name             = 'xUtil'
  s.version          = '2.0.0.1'
  s.summary          = 'UI无关基础组件库'

  s.description      = <<-DESC
    UI无关基础组件库
                       DESC

  s.homepage         = 'https://github.com/jinsikui/xUtil'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jinsikui' => '1811652374@qq.com' }
  s.source           = { :git => 'https://github.com/jinsikui/xUtil.git'}
  s.ios.deployment_target = '9.0'
  s.source_files = 'Source/Classes/xUtil.h'
  s.dependency 'KVOController'
  s.dependency 'PromisesObjC'
  s.dependency 'YYText'
  s.dependency 'SocketRocket'
  s.dependency 'SDWebImage'
  s.dependency 'AFNetworking', '~> 4.0.0'
  s.dependency 'FMDB'
  
  s.subspec 'Helpers' do |sh|
    sh.source_files = 'Source/Classes/Helpers/*'
  end
  
  s.subspec 'Services' do |ss|
    ss.source_files = 'Source/Classes/Services/*'
  end

end
