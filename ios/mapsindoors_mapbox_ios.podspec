#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mapsindoors.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mapsindoors_mapbox_ios'
  s.version          = '4.7.3'
  s.summary          = 'Mapsindoors flutter plugin'
  s.homepage         = 'http://mapspeople.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mapspeople' => 'info@mapspeople.com' }
  s.source           = { :path => '.' }
  s.source_files = 'mapsindoors_mapbox_ios/Sources/mapsindoors_mapbox_ios/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'
  s.ios.deployment_target = "15.0"

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.10'

  s.dependency 'MapsIndoorsCodable', "4.17.3"
  s.dependency 'MapsIndoorsMapbox11', "4.17.3"
end
