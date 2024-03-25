#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mapsindoors.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mapsindoors_mapbox_ios'
  s.version          = '2.1.5'
  s.summary          = 'Mapsindoors flutter plugin'
  s.homepage         = 'http://mapspeople.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mapspeople' => 'info@mapspeople.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'

  s.dependency 'MapsIndoorsCodable', "4.3.8"
  s.dependency 'MapsIndoorsMapbox', "4.3.8"
end
