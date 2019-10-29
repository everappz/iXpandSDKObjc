Pod::Spec.new do |s|
  s.name         = "iXpandSDKObjc"
  s.version      = "1.0.1"
  s.summary      = "iXpand Objc SDK for SANDISK IXPAND: https://developer.westerndigital.com/develop/sandisk/ixpand-sdk-home-main.html"
  s.homepage     = "https://github.com/leshkoapps/iXpandSDKObjc"
  s.license      = 'MIT'
  s.author       = { "Artem Meleshko" => "support@everappz.com" }
  s.source       = { :git => "https://github.com/leshkoapps/iXpandSDKObjc.git", :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'SDK/*.{h,m}'
  s.requires_arc = true
  s.vendored_framework = 'Frameworks/iXpandSDKlib.framework', 'Frameworks/iXpandSDKlibSim.framework'
  s.libraries        = 'c++', 'z', 'c'
  s.compiler_flags = '-lc', '-lc++', '-lz'
  s.ios.framework  = 'MobileCoreServices', 'ExternalAccessory', 'CoreFoundation', 'Foundation', 'SystemConfiguration', 'CFNetwork', 'Security'
  s.xcconfig = {'OTHER_LDFLAGS[sdk=iphonesimulator*]' => '$(inherited) -framework "iXpandSDKlibSim"', 'OTHER_LDFLAGS[sdk=iphoneos*]' => '$(inherited) -framework "iXpandSDKlib"' }
end
