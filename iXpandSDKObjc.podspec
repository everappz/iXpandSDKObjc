Pod::Spec.new do |s|
  s.name         = "iXpandSDKObjc"
  s.version      = "1.0.3"
  s.summary      = "iXpand Objc SDK for SANDISK IXPAND: https://developer.westerndigital.com/develop/sandisk/ixpand-sdk-home-main.html"
  s.homepage     = "https://github.com/leshkoapps/iXpandSDKObjc"
  s.license      = 'MIT'
  s.author       = { "Artem Meleshko" => "support@everappz.com" }
  s.source       = { :git => "https://github.com/leshkoapps/iXpandSDKObjc.git", :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'SDK/*.{h,m}'
  s.requires_arc = true
  s.preserve_paths = 'Frameworks/*.framework'
  ixpand_framework_os =  'iXpandSDKlib'
  ixpand_framework_sim =  'iXpandSDKlibSim'
  other_frameworks_common =  ['MobileCoreServices', 'ExternalAccessory', 'CoreFoundation', 'Foundation', 'SystemConfiguration', 'CFNetwork', 'Security']
  other_ldflags_os = '$(inherited) -framework ' + other_frameworks_common.join(' -framework ') + ' -framework ' + ixpand_framework_os + 
    ' -lz -lstdc++ -lc'
  other_ldflags_sim = '$(inherited) -framework ' + other_frameworks_common.join(' -framework ') + ' -framework ' + ixpand_framework_sim +
    ' -lz -lstdc++ -lc'
  s.xcconfig     = { 
    'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_ROOT)/iXpandSDKObjc/Frameworks"',
    'OTHER_LDFLAGS[arch=i386]'  => other_ldflags_sim,
    'OTHER_LDFLAGS[arch=x86_64]'  => other_ldflags_sim,
    'OTHER_LDFLAGS[arch=arm64]'  => other_ldflags_os,
    'OTHER_LDFLAGS[arch=armv7]'  => other_ldflags_os,
    'OTHER_LDFLAGS[arch=armv7s]' => other_ldflags_os
  }
end
