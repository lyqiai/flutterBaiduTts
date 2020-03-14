#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_baidutts.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_baidutts'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin.'
  s.description      = <<-DESC
A new Flutter plugin.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.static_framework = true
  s.resources = 'Classes/**/*.dat'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.frameworks = 'Accelerate', 'AudioToolbox', 'AVFoundation', 'CFNetwork', 'CoreLocation', 'CoreTelephony', 'GLKit', 'SystemConfiguration'
  s.libraries = 'c++', 'iconv', 'sqlite3', 'z'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'
end
