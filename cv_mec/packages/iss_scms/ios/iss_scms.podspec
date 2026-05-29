#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint iss_scms.podspec` to validate before publishing.
#
require_relative 'download_xcframework'

Pod::Spec.new do |s|
  s.name             = 'iss_scms'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*' #, 'Dependencies/swift-algorithms/Sources/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  lib_encoder_lib_url = 'https://github.com/TrafficAuth/trafficauth-sdk-ios/releases/download/v1.0.2/libEncoderLib.xcframework.zip'
  traffic_auth_url = 'https://github.com/TrafficAuth/trafficauth-sdk-ios/releases/download/v1.0.2/TrafficAuthSDK.xcframework.zip'
  
  lib_encoder_lib_path = download_remote_xcframework(lib_encoder_lib_url, 'Frameworks', 'libEncoderLib')
  traffic_auth_path = download_remote_xcframework(traffic_auth_url, 'Frameworks', 'TrafficAuthSDK')

  s.vendored_frameworks = [
    'Frameworks/libEncoderLib.xcframework', 
    'Frameworks/TrafficAuthSDK.xcframework'
  ]
  s.frameworks = ['TrafficAuthSDK']


  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'iss_scms_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end

